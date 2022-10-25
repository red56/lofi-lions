# frozen_string_literal: true

RSpec.configure do
  def dom_class(record_or_class, prefix = nil)
    ActionView::RecordIdentifier.dom_class(record_or_class, prefix)
  end

  # very similar to ApplicationDecorator#dom_id and a bit like ActionView::RecordIdentifier#dom_id
  def dom_id(record)
    if record.new_record?
      # rails generates "new_model", but haml generates "model_new", so we follow haml
      [dom_class(record), "new"].join(ActionView::RecordIdentifier::JOIN)
    else
      [dom_class(record), record.id].join(ActionView::RecordIdentifier::JOIN)
    end
  end

  def dom_id_as_selector(record)
    "##{dom_id(record)}"
  end
end
