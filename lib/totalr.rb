require 'active_support/inflector'

module Totalr
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def total(coll_name, options = {})
      attribute = options[:using]
      group_by = options[:by]
      method_name = options[:as]
      method_name ||= "total_#{ActiveSupport::Inflector.singularize(coll_name.to_s)}_#{attribute}_for_#{group_by}" if attribute and group_by
      method_name ||= "total_#{ActiveSupport::Inflector.singularize(coll_name.to_s)}_#{attribute}" if attribute
      method_name ||= "total_#{coll_name}_for_#{group_by}" if group_by
      method_name ||= "total_#{coll_name}"

      method_body = if group_by
                      if attribute
                        lambda do |group_value|
                          coll = send(coll_name)
                          coll.select {|e| e.send(group_by) == group_value}.map {|e| e.send(attribute)}.inject(:+)
                        end
                      else
                        lambda do |group_value|
                          coll = send(coll_name)
                          coll.select {|e| e.send(group_by) == group_value}.length
                        end
                      end

                    else
                      if attribute
                        lambda do
                          coll = send(coll_name)
                          coll.map {|e| e.send(attribute)}.inject(:+)
                        end
                      else
                        lambda do
                          coll = send(coll_name)
                          coll.length
                        end
                      end
                    end
      define_method method_name, method_body
    end

    def percentage(part_count_method, options = {})
      total_count_method = options[:of]
      part_by = options[:by]
      total_by = options[:total_by]

      method_name = options[:as]
      method_name ||= "percentage_#{part_count_method}_in_#{total_by}" if total_by
      method_name ||= "percentage_#{part_count_method}"

      if total_by and total_by != part_by
        define_method method_name do |part_by_value, total_by_value|
          part_count = send(part_count_method, part_by_value)
          total_count = total_by ? send(total_count_method, total_by_value) : send(total_count_method)
          part_count * 100.00 / total_count
        end

      else
        define_method method_name do |part_by_value|
          part_count = send(part_count_method, part_by_value)
          total_count = total_by ? send(total_count_method, part_by_value) : send(total_count_method)
          part_count * 100.00 / total_count
        end
      end
    end
  end
end
