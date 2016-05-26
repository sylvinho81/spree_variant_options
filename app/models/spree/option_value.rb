module Spree
  class OptionValue < Spree::Base
    belongs_to :option_type, class_name: 'Spree::OptionType', touch: true, inverse_of: :option_values
    acts_as_list scope: :option_type
    has_and_belongs_to_many :variants, join_table: 'spree_option_values_variants', class_name: "Spree::Variant"

    validates :name, presence: true, uniqueness: { scope: :option_type_id }
    validates :presentation, presence: true

    after_touch :touch_all_variants

    self.whitelisted_ransackable_attributes = ['presentation']

    def touch_all_variants
      variants.update_all(updated_at: Time.current)
    end

    has_attached_file :image,
                      :styles        => { mini: '32x32>', normal: '128x128>' },
                      :default_style => SpreeVariantOptions::VariantConfig[:option_value_default_style],
                      :url           => SpreeVariantOptions::VariantConfig[:option_value_url],
                      :path          => SpreeVariantOptions::VariantConfig[:option_value_path]

    def has_image?
      image_file_name && !image_file_name.empty?
    end

    default_scope { order("#{quoted_table_name}.position") }
    scope :for_product, lambda { |product| select("DISTINCT #{table_name}.*").joins(:variants).where("spree_option_values_variants.variant_id IN (?)", product.variant_ids) }


  end
end
