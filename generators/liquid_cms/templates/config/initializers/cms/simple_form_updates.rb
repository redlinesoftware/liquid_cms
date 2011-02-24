class SimpleForm::FormBuilder
  def commit_button_or_cancel
    @template.content_tag :div, :class => 'buttons' do
      String.new.tap do |html|
        html << button(:submit)
        html << " or "
        html << template.link_to(t('simple_form.buttons.cancel'), :back, :class => 'cancel')
      end
    end
  end
end
