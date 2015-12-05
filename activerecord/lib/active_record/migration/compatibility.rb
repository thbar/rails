module ActiveRecord
  class Migration
    module Compatibility # :nodoc: all
      V5_0 = Current

      module FourTwoShared
        module TableDefinition
          def references(*, **options)
            options[:index] ||= false
            super
          end
          alias :belongs_to :references

          def timestamps(*, **options)
            options[:null] = true if options[:null].nil?
            super
          end
        end

        def create_table(table_name, options = {})
          if block_given?
            super(table_name, options) do |t|
              class << t
                prepend TableDefinition
              end
              yield t
            end
          else
            super
          end
        end

        def add_reference(*, **options)
          options[:index] ||= false
          super
        end
        alias :add_belongs_to :add_reference

        def add_timestamps(*, **options)
          options[:null] = true if options[:null].nil?
          super
        end
      end

      class V4_2 < V5_0
        # 4.2 is defined as a module because it needs to be shared with
        # Legacy. When the time comes, V5_0 should be defined straight
        # in its class.
        include FourTwoShared
      end

      module Legacy
        include FourTwoShared

        def run(*)
          ActiveSupport::Deprecation.warn \
            "Directly inheriting from ActiveRecord::Migration is deprecated. " \
            "Please specify the Rails release the migration was written for:\n" \
            "\n" \
            "  class #{self.class.name} < ActiveRecord::Migration[4.2]"
          super
        end
      end
    end
  end
end
