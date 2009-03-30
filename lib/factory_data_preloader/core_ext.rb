# http://github.com/rails/rails/tree/823b623fe2de8846c37aa13250010809ac940b57/activesupport/lib/active_support/core_ext/object/misc.rb

unless Object.respond_to?(:try) # Object#try is in Rails 2.3 but not in 2.2.
  class Object
    # Tries to send the method only if object responds to it. Return +nil+ otherwise.
    # It will also forward any arguments and/or block like Object#send does.
    # 
    # ==== Example :
    # 
    # # Without try
    # @person ? @person.name : nil
    # 
    # With try
    # @person.try(:name)
    #
    # # try also accepts arguments/blocks for the method it is trying
    # Person.try(:find, 1)
    # @people.try(:map) {|p| p.name}
    def try(method, *args, &block)
      send(method, *args, &block) if respond_to?(method, true)
    end
  end
end