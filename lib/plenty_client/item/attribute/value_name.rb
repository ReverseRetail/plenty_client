module PlentyClient
  module Item
    module Attribute
      class ValueName
        extend PlentyClient::Endpoint
        extend PlentyClient::Request

        ITEM_ATTRIBUTE_PATH    = '/items/attribute_values'.freeze

        CREATE_ITEM_ATTRIBUTE_VALUES  = '/{attributeValueId}/names'.freeze
        LIST_ITEM_ATTRIBUTE_VALUE     = '/{attributeValueId}/names'.freeze
        GET_ITEMS_ATTRIBUTE_VALUE     = '/{attributeValueId}/names/{lang}'.freeze
        UPDATE_ITEMS_ATTRIBUTE_VALUE  = '/{attributeValueId}/names/{lang}'.freeze
        DELETE_ITEMS_ATTRIBUTE_VALUE  = '/{attributeValueId}/names/{lang}'.freeze

        class << self
          def create(attribute_value_id, body = {})
            post(build_endpoint("#{ITEM_ATTRIBUTE_PATH}#{CREATE_ITEM_ATTRIBUTE_VALUES}"),
                                attribute_value: attribute_value_id,
                                body)
          end

          def list(attribute_value_id, headers = {}, &block)
            get(build_endpoint("#{ITEM_ATTRIBUTE_PATH}#{LIST_ITEM_ATTRIBUTE_VALUE}"),
                                attribute_value: attribute_value_id,
                                headers, &block)
          end

          def find(attribute_value_id, lang, headers = {}, &block)
            get(build_endpoint("#{ITEM_ATTRIBUTE_PATH}#{GET_ITEMS_ATTRIBUTE_VALUE}",
                               attribute_value: attribute_value_id,
                               lang: lang),
                               headers, &block)
          end

          def update(attribute_value_id, lang, body = {}, &block)
            put(build_endpoint("#{ITEM_ATTRIBUTE_PATH}#{UPDATE_ITEMS_ATTRIBUTE_VALUE}",
                               attribute_value: attribute_value_id,
                               lang: lang),
                               body, &block)
          end

          def delete(attribute_value_id, value_id)
            delete(build_endpoint("#{ITEM_ATTRIBUTE_PATH}#{DELETE_ITEMS_ATTRIBUTE_VALUE}",
                                  attribute_value: attribute_value_id,
                                  lang: lang))
          end
        end
      end
    end
  end
end