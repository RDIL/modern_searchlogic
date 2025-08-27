module ModernSearchlogic
  module ColumnConditions
    module ClassMethods
      def respond_to_missing?(method, *)
        super || valid_searchlogic_scope?(method)
      end

      def valid_searchlogic_scope?(method)
        return false if connection.tables.empty?
        return false if method =~ /^define_method_/

        searchlogic_scope_dynamically_defined?(method) ||
          !!searchlogic_column_condition_method_block(method.to_s) ||
          _defined_scopes.include?(method.to_sym)
      end

      def dynamically_define_searchlogic_method(method)
        return true if searchlogic_scope_dynamically_defined?(method)
        return false unless searchlogic_scope = searchlogic_column_condition_method_block(method.to_s)
        singleton_class.__send__(:define_method, method, &searchlogic_scope[:block])
        self._dynamically_defined_searchlogic_scopes = self._dynamically_defined_searchlogic_scopes.merge(method => searchlogic_scope)
        true
      end

      def searchlogic_method_arity(method)
        method = method.to_sym
        raise ArgumentError, "Not a searchlogic scope" unless valid_searchlogic_scope?(method)
        dynamically_define_searchlogic_method(method)

        searchlogic_scope_dynamically_defined?(method) ?
          _dynamically_defined_searchlogic_scopes[method][:arity] :
          self.method(method).arity
      end

      private

      def searchlogic_scope_dynamically_defined?(method)
        _dynamically_defined_searchlogic_scopes.key?(method)
      end

      def searchlogic_suffix_condition(suffix, options = {}, &method_block)
        searchlogic_suffix_conditions[suffix] = [options, method_block]
      end

      def searchlogic_prefix_condition(prefix, &method_block)
        searchlogic_prefix_conditions[prefix] = method_block
      end

      def searchlogic_extract_arel_compatible_value(value)
        if value.respond_to?(:map) && !value.acts_like?(:string)
          value.map { |v| searchlogic_extract_arel_compatible_value(v) }
        elsif value.is_a?(ActiveRecord::Base)
          value.id
        else
          value
        end
      end

      def searchlogic_arel_alias(searchlogic_suffix, arel_method, options = {})
        value_mapper = options.fetch(:map_value, -> (x) { searchlogic_extract_arel_compatible_value(x) })

        searchlogic_suffix_condition "_#{searchlogic_suffix}", options do |column_name, *args|
          values = coerce_and_validate_args_for_arel_aliases!(args, options)
          arel_table[column_name].__send__(arel_method, value_mapper.call(values))
        end

        searchlogic_suffix_condition "_#{searchlogic_suffix}_any", options do |column_name, *args|
          values = coerce_and_validate_args_for_arel_aliases!(args, options.merge(:any_or_all => true))
          arel_table[column_name].__send__("#{arel_method}_any", values.map(&value_mapper))
        end

        searchlogic_suffix_condition "_#{searchlogic_suffix}_all", options do |column_name, *args|
          values = coerce_and_validate_args_for_arel_aliases!(args, options.merge(:any_or_all => true))
          arel_table[column_name].__send__("#{arel_method}_all", values.map(&value_mapper))
        end
      end

      def searchlogic_active_record_alias(searchlogic_suffix, options = {}, &block)
        searchlogic_suffix_condition "_#{searchlogic_suffix}" do |column_name, *args|
          raise ArgumentError, "wrong number of arguments (0 for >= 1)" if args.empty?
          raise ArgumentError, "unsupported searchlogic suffix #{searchlogic_suffix} passed" unless [:in, :not_in].include?(searchlogic_suffix)

          relation = unscoped { instance_exec(column_name, args, &block) }
          if ActiveRecord::VERSION::MAJOR >= 5
            relation.where_clause&.ast
          elsif [3, 4].include?(ActiveRecord::VERSION::MAJOR)
            relation.where_values.reduce(&:and)
          end
        end
      end

      def searchlogic_suffix_condition_match(method_name)
        suffix_regexp = searchlogic_suffix_conditions.keys.join('|')
        if match = method_name.match(/\A(#{column_names_regexp}(?:_or_#{column_names_regexp})*)(#{suffix_regexp})\z/)
          options, method_block = searchlogic_suffix_conditions.fetch(match[2])
          column_names = match[1].split('_or_')

          arity = calculate_arity(method_block)

          {
            arity: arity,
            block: lambda do |*args|
              validate_argument_count!(arity, args.length) if arity >= 0
              arel_nodes = column_names.map do |n|
                instance_exec(n, *args, &method_block)
              end
              where(arel_nodes.reduce(:or))
            end
          }
        end
      end

      def searchlogic_prefix_match(method_name)
        prefix_regexp = searchlogic_prefix_conditions.keys.join('|')
        if match = method_name.match(/\A(#{prefix_regexp})(#{column_names_regexp})\z/)
          method_block = searchlogic_prefix_conditions.fetch(match[1])

          arity = calculate_arity(method_block)

          {
            arity: arity,
            block: lambda do |*args|
              validate_argument_count!(method_block.arity - 1, args.length) if method_block.arity >= 1
              instance_exec(match[2], *args, &method_block)
            end
          }
        elsif match = method_name.match(/\A(#{prefix_regexp})(#{association_names_regexp})_(\S+)\z/)
          prefix, association_name, rest = match.to_a.drop(1)

          searchlogic_association_finder_method(association_by_name.fetch(association_name.to_sym), prefix + rest)
        end
      end

      def searchlogic_association_suffix_match(method_name)
        if match = method_name.match(/\A(#{association_names_regexp})_(\S+)\z/)
          searchlogic_association_finder_method(association_by_name.fetch(match[1].to_sym), match[2])
        end
      end

      def searchlogic_column_boolean_match(method_name)
        if match = method_name.match(/^not_(.*)/)
          column_name = match[1]
          if boolean_column?(column_name)
            {arity: 0, block: lambda { where(column_name => false) }}
          end
        elsif boolean_column?(method_name)
          {arity: 0, block: lambda { where(method_name => true)}}
        end
      end

      def boolean_column?(name)
        column = columns_hash[name.to_s]
        column && column.type == :boolean
      end

      def searchlogic_association_finder_method(association, method_name)
        method_name = method_name.to_sym
        if !association.options[:polymorphic] && association.klass.valid_searchlogic_scope?(method_name)
          arity = association.klass.searchlogic_method_arity(method_name)

          {
            arity: arity,
            block: lambda do |*args|
              joins(association.name).merge(association.klass.__send__(method_name, *args))
            end
          }
        end
      end

      def association_by_name
        reflect_on_all_associations.each.with_object({}) do |assoc, obj|
          obj[assoc.name] = assoc
        end
      end

      def association_names_regexp
        association_by_name.keys.join('|')
      end

      def searchlogic_column_condition_method_block(method)
        return if self == ActiveRecord::Base

        method = method.to_s
        searchlogic_prefix_match(method) ||
          searchlogic_suffix_condition_match(method) ||
          searchlogic_association_suffix_match(method) ||
          searchlogic_column_boolean_match(method)
      end

      def column_names_regexp
        "(?:#{column_names.join('|')})"
      end

      def method_missing(method, *args, &block)
        return super if connection.tables.empty?
        return super unless dynamically_define_searchlogic_method(method)

        __send__(method, *args, &block)
      end

      def coerce_and_validate_args_for_arel_aliases!(args, options)
        any_or_all = options[:any_or_all]

        if options[:takes_array_args]
          args = [any_or_all ? args : args.flatten]
        elsif any_or_all
          args = [args.flatten]
        end

        if any_or_all
          raise ArgumentError, "wrong number of arguments (0 for >= 1)" if args.first.length.zero?
        elsif args.length != 1
          raise ArgumentError, "wrong number of arguments (#{args.length} for 1)"
        end

        args.first
      end

      def validate_argument_count!(expected_args, actual_args)
        if expected_args != actual_args
          raise ArgumentError, "wrong number of arguments (#{actual_args} for #{expected_args})"
        end
      end

      def calculate_arity(block)
        block.arity > 0 ? block.arity - 1 : block.arity + 1
      end
    end

    def self.included(base)
      base.extend ClassMethods

      base.class_eval do
        class_attribute :searchlogic_suffix_conditions
        self.searchlogic_suffix_conditions = {}

        class_attribute :searchlogic_prefix_conditions
        self.searchlogic_prefix_conditions = {}

        searchlogic_arel_alias :equals, :eq
        searchlogic_arel_alias :eq, :eq
        searchlogic_arel_alias :is, :eq
        searchlogic_arel_alias :does_not_equal, :not_eq
        searchlogic_arel_alias :ne, :not_eq
        searchlogic_arel_alias :not_eq, :not_eq
        searchlogic_arel_alias :not, :not_eq
        searchlogic_arel_alias :is_not, :not_eq
        searchlogic_arel_alias :greater_than, :gt
        searchlogic_arel_alias :gt, :gt
        searchlogic_arel_alias :less_than, :lt
        searchlogic_arel_alias :lt, :lt
        searchlogic_arel_alias :greater_than_or_equal_to, :gteq
        searchlogic_arel_alias :gte, :gteq
        searchlogic_arel_alias :less_than_or_equal_to, :lteq
        searchlogic_arel_alias :lte, :lteq
        searchlogic_active_record_alias :in do |column, values|
          has_nil = values.include?(nil)
          values = values.flatten.compact
          subs = [values]
          if has_nil
            subs << nil
          end
          where(column => searchlogic_extract_arel_compatible_value(subs))
        end
        searchlogic_active_record_alias :not_in do |column, values|
          values = searchlogic_extract_arel_compatible_value(values.flatten)
          query = values.map { "#{connection.quote_table_name(arel_table.name)}.#{connection.quote_column_name(column)} != ?" }.join(" AND ")
          where(query, *values)
        end

        searchlogic_arel_alias :like, :matches, :map_value => -> (val) { "%#{val}%" }
        searchlogic_arel_alias :begins_with, :matches, :map_value => -> (val) { "#{val}%" }
        searchlogic_arel_alias :ends_with, :matches, :map_value => -> (val) { "%#{val}" }
        searchlogic_arel_alias :not_like, :does_not_match, :map_value => -> (val) { "%#{val}%" }
        searchlogic_arel_alias :not_begin_with, :does_not_match, :map_value => -> (val) { "#{val}%" }
        searchlogic_arel_alias :not_end_with, :does_not_match, :map_value => -> (val) { "%#{val}" }

        searchlogic_suffix_condition '_blank' do |column_name|
          arel_table[column_name].eq(nil).or(arel_table[column_name].eq(''))
        end

        searchlogic_suffix_condition '_present' do |column_name|
          arel_table[column_name].not_eq(nil).and(arel_table[column_name].not_eq(''))
        end

        null_matcher = lambda { |column_name| arel_table[column_name].eq(nil) }
        searchlogic_suffix_condition '_null', &null_matcher
        searchlogic_suffix_condition '_nil', &null_matcher

        not_null_matcher = lambda { |column_name| arel_table[column_name].not_eq(nil) }
        searchlogic_suffix_condition '_not_null', &not_null_matcher
        searchlogic_suffix_condition '_not_nil', &not_null_matcher

        searchlogic_prefix_condition 'descend_by_' do |column_name|
          order(arel_table[column_name].desc)
        end

        searchlogic_prefix_condition 'ascend_by_' do |column_name|
          order(arel_table[column_name].asc)
        end
      end
    end
  end
end
