RSpec.shared_examples "a sluggable model" do
  let(:model_factory) { described_class.model_name.singular.to_sym }
  # `source_attribute` мы будем передавать из основного теста (например, :title)

  it 'generates a slug on creation' do
    record = create(model_factory, source_attribute => 'A New Title!')
    expect(record.slug).to eq('a-new-title')
  end

  it 'creates a redirect when the source attribute is updated' do
    record = create(model_factory, source_attribute => 'Old Title')
    original_slug = record.slug

    expect {
      record.update!(source_attribute => 'New Title')
    }.to change(SlugRedirect, :count).by(1)

    expect(record.slug).to eq('new-title')
    expect(SlugRedirect.last.old_slug).to eq(original_slug)
  end
end
