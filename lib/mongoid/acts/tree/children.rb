module Mongoid
	module Acts
		module Tree


			class Children < Mongoid::Criteria

				def initialize(owner, tree_base_class)
					@parent = owner
					@tree_base_class = tree_base_class
					super(tree_base_class)
					other = self.merge!(tree_base_class.where(@parent.parent_id_field => @parent.id).order_by(@parent.tree_order))
				end

				alias_method :size, :count

				def build(attributes)
					child = @parent.class.new(attributes)
					child.parent = @parent
					child
				end

				def create(attributes)
					child = self.build(attributes)
					child.save
					child
				end

				def <<(object)
					object.parent = @parent
					object.save
				end
				alias push <<

				def replace_with(new_objects)
					new_object_ids = new_objects.collect(&:id)
					existing_objects = self.to_a
					existing_object_ids = existing_objects.collect(&:id)

					self.to_a.each { |existing| existing.clear_parent_information! unless new_object_ids.include?(existing.id) }
					new_objects.each { |new_object| self << new_object unless existing_object_ids.include?(new_object.id) }
				end

				#Clear children list
				def clear!
					self.each(&:destroy)
				end

			end # Children


		end # Tree
	end # Acts
end # Mongoid
