# All remote actions are automatically enabled to show a gui indicator during a remote call with this plugin.
#
# == Note
#
# If you have installed another plugin that overrides rails methods such as <tt>remote_function</tt>,
# <tt>form_remote_tag</tt>, or <tt>submit_to_remote</tt> then this plugin may not work as intended. So if
# you find that some methods aren't working as expected then this could be a possible problem.  This also
# holds for the other plugins overriding the same methods.

# Default values that can be overridden in <tt>environment.rb</tt>
#
# * <tt>default_image</tt> - The default image indicator
# * <tt>default_id</tt> - The default css id given to the indicator
# * <tt>default_class</tt> - The default css class given to the indicator
# * <tt>enable_all</tt> - Enable remote indicators on all remote functions by default
# * <tt>effect</tt> - The default effect to apply to the indicator when it is shown(before) and hidden(after)
#
# == Examples
#
# * <tt>RemoteIndicator.default_image = 'spinner.gif'</tt>
# * <tt>RemoteIndicator.default_id = 'spinner'</tt>
# * <tt>RemoteIndicator.default_class = 'spinner'</tt>
# * <tt>RemoteIndicator.enable_all = false</tt>
# * <tt>RemoteIndicator.effect = {:before => 'new Effect.Appear', :after => 'new Effect.Fade'}</tt>
class RemoteIndicator
  @@default_image = 'indicator.gif'
  cattr_accessor :default_image

  @@default_id    = 'indicator'
  cattr_accessor :default_id

  @@default_class = 'indicator'
  cattr_accessor :default_class

  @@enable_all = true
  cattr_accessor :enable_all
  
  @@effect = {:before => 'Element.show', :after => 'Element.hide'}
  cattr_accessor :effect
end

# Progress indication is built in using the <tt>indicator</tt> method and the optional <tt>:indicator</tt> option for remote calls.
# See <tt>remote_function</tt> documentation for more information.
#
# The <tt>:indicator</tt> options adds the functionality of using a remote indicator (an image) during the execution
# of all remote functions.
#
# Functionality added to disable the form by default during a remote call using methods such as <tt>remote_function</tt>,
# <tt>form_remote_tag</tt>, <tt>remote_form_for</tt> and <tt>submit_to_remote</tt>.
#
# This is useful to prevent a user from submitting a form twice while a remote call is in progress
# since the submit button will be disabled and therefore not clickable.
#
# Additional options:
# * <tt>:indicator</tt> - The css id of an element to show and hide during a remote call.
#   Defaults to <tt>RemoteIndicator.default_id</tt>.
#   Set :indicator to false if no indicator is to be used.
#   Set :indicator to true in order to use the default indicator (<tt>RemoteIndicator.default_id</tt>).
#   If RemoteIndicator.enable_all is set to true, :indicator => true is not required.
#   Set :indicator to a hash with the :toggle option to replace the current element with the dom element specified by :toggle. Ex. <tt>:indicator => {:toggle => dom_id(object)}</tt>
# * <tt>:disable_form</tt> - Specifies if the form will disable or not during the remote call.
#   Defaults to true.
#   Set :disable_form to false to keep the form enabled during a remote function call.
# * <tt>:before_effect</tt> - Specifies the before 'effect' for the indicator.
#   Defaults to 'Element.show'.
# * <tt>:after_effect</tt> - Specifies the after 'effect' for the indicator.
#   Defaults to 'Element.hide'.
module ActionView::Helpers::PrototypeHelper

  # Creates an indicator image.  The options supplied are the same used with +image_tag+
  #
  # === Examples
  # 
  # Using a custom indicator id
  #   <%= indicator :id => 'spinner' %>
  #
  # Shorthand using a string for the options (sets the :id automatically)
  #   <%= indicator 'spinner' %>
  #
  # Toggle the current link with an indicator
  #   <%= link_to_remote image_tag('add.png'), :url => do_something_path, :indicator => {:toggle => 'spinner'} %> <%= indicator 'spinner' %>
  #
  # Using many indicators on the same page 
  #   <% collection.each do |id| %>
  #     <%= link_to_remote :url => do_something_path, :indicator => "link#{id}" %> <%= indicator :id => "link#{id}" %>
  #   <% end %>
  def indicator(options = {})
    indicator_image indicator_options(options)
  end

  # Sets the proper options for custom indicators.
  #
  # Current and additional options are:
  # * <tt>:id</tt> - The css id of the indicator.  Defaults to <tt>RemoteIndicator.default_id</tt>
  # * <tt>:class</tt> - The css class of the indicator.  Defaults to <tt>RemoteIndicator.default_class</tt>
  # * <tt>:hide</tt> - Hide the image by default.  Defaults to true.
  #
  # === Example
  #
  # Create an indicator with text
  #   <%= content_tag 'span', 'Updating Data... ', indicator_options %>
  # 
  # Pass any options you'd normally use to the method itself
  #   <%= content_tag 'span', 'Updating Data... ', indicator_options(:style => 'width:100px')
  def indicator_options(options = {})
    # if options is a string then use it as the :id value
    options = {:id => options} if options.is_a?(String)

    options.reverse_merge!(:id => RemoteIndicator.default_id, :class => RemoteIndicator.default_class, :hide => true)
    options[:style] = [options[:style], 'display:none'].compact.join(';') if options.delete(:hide)
    options
  end

  # Creates an indicator image.  The options supplied are the same used with +image_tag+
  #
  # This method differs from +indicator+ in that it simply produces the indicator image without
  # the additional indicator options to for hiding the image by default etc.  Without the
  # additional options, this method can create the standalone indicator image for use in more
  # complex indicators that use the image in combination with additional markup.
  # 
  # === Example
  #
  # <%= content_tag 'div', 'Updating Data... ' + indicator_image, indicator_options %>
  def indicator_image(options = {})
    image_tag RemoteIndicator.default_image, options
  end

  alias :remote_function_old :remote_function

  # === Examples
  #
  # * To use the default values - <tt><%= remote_function :url => {:action => 'dosomething'} %> <%= indicator %></tt>
  # * To disable the gui indicator - <tt><%= remote_function :url => {:action => 'dosomething'}, :indicator => false %></tt>
  # * To use a custom :id - <tt><%= remote_function :url => {:action => 'dosomething'}, :indicator => 'custom' %> <%= indicator :id => 'custom' %></tt>
  # * To fade the indicator instead of simply hiding it - <tt><%= remote_function(:update => 'someid', :url => {:action => 'dosomething'}, :after_effect => 'new Effect.Fade') %></tt>
  #
  # === Examples using :disable_form
  # See module documentation for usage of the <tt>:disable_form</tt> option.
  #
  # Automatically disables a form (no additional options)
  #   <%= remote_function(:update => 'someid', :submit => 'myform', :url => {:action => 'dosomething'}) %>
  #
  # Prevents a form from being disabled
  #   <%= remote_function(:update => 'someid', :submit => 'myform', :url => {:action => 'dosomething'}, :disable_form => false) %>
  #
  # No form disabled as no :submit option is provided
  #   <%= remote_function(:update => 'someid', :url => {:action => 'dosomething'}) %>
  #
  # ==== IMPORTANT GOTCHA
  # Don't forget to use <tt><%= indicator %></tt> on the page with remote calls or the javascript will fail
  # and your action won't complete (In development mode you will be shown an alert if the indicator has not been defined).
  # This doesn't apply if you set the indicator to false... <tt>:indicator => false</tt>.
  def remote_function(options)
    options[:indicator] = RemoteIndicator.default_id if options[:indicator] == true || (options[:indicator].nil? && RemoteIndicator.enable_all)

    if indicator = options.delete(:indicator)
      options.reverse_merge! :before_effect => RemoteIndicator.effect[:before], :after_effect => RemoteIndicator.effect[:after]

      indicator = indicator[:toggle] if (toggle = indicator.is_a?(Hash))
    
      before_js = String.new.tap do |js|
        js << "Element.hide(this);" if toggle
        js << "#{options[:before_effect]}('#{indicator}')"
      end

      after_js = String.new.tap do |js|
        js << "#{options[:after_effect]}('#{indicator}')"
        js << ";Element.show(this)" if toggle
      end

      event_options = {
        :before => (RAILS_ENV == 'development' ? "try { #{before_js} } catch(e) { alert('The remote helper indicator \\'#{indicator}\\' has not been defined.\\n\\nEither define the indicator with the \\'indicator\\' method or pass :indicator => false as an option to disable the indicator.') }" : before_js),
        :complete => after_js
      }

      merge_option_values! options, event_options
    end

    add_disable_options! options
    remote_function_old(options)
  end

  alias :form_remote_tag_old :form_remote_tag
  
  # See module documentation for usage of the <tt>:disable_form</tt> option.
  # See <tt>remote_function</tt> documentation for usage of the <tt>:indicator</tt> option.
  #
  # === Examples
  #
  # Automatically disables a form (no additional options)
  #   <%= form_remote_tag(:url => {:action => 'dosomething'}) %>
  #
  # Prevents the form from being disabled
  #   <%= form_remote_tag(:url => {:action => 'dosomething'}, :disable_form => false) %>
  def form_remote_tag(options = {}, &block)
    options.reverse_merge! :disable_form => true

    if options.delete(:disable_form)
      # we can't disable using :before because disabled fields aren't serialized, must use :after
      merge_option_values! options, {
        :before => 'var form = $(this), disabled_elems = []',
        # save form elements that are already disabled
        :after => "disabled_elems = form.select(':disabled'); Form.disable(form)",
        # re-disable any previously disabled elements
        :complete => "Form.enable(form); disabled_elems.invoke('disable')"
      }
    end
    
    form_remote_tag_old(options, &block)
  end

  alias :submit_to_remote_old :submit_to_remote

  # See module documentation for usage of the <tt>:disable_form</tt> option.
  # See <tt>remote_function</tt> documentation for usage of the <tt>:indicator</tt> option.
  #
  # The option <tt>:disable_form</tt> disables a form (specified using the :submit option)
  #
  # === Example
  #
  # Automatically disables a form (no additional options)
  #   <%= submit_to_remote('name', 'Submit', :submit => 'myform', :url => {:action => 'dosomething'}) %>
  #
  # Prevents a form from being disabled
  #   <%= submit_to_remote('name', 'Submit', :submit => 'myform', :url => {:action => 'dosomething'}, :disable_form => false) %>
  def submit_to_remote(name, value, options = {})
    add_disable_options! options
    submit_to_remote_old(name, value, options)
  end

private
  def add_disable_options!(options)
    options.reverse_merge! :disable_form => true

    if options.delete(:disable_form) && options[:submit]
      # we can't disable using :before because disabled fields aren't serialized, must use :after
      merge_option_values! options, {:after => "Form.disable('#{options[:submit]}')", :complete => "Form.enable('#{options[:submit]}')"}
    end
  end
  
  def merge_option_values!(options, code, sep = ';')
    code.each_pair {|key,value| options[key] = [value, options[key]].compact.join(sep)}
  end
end
