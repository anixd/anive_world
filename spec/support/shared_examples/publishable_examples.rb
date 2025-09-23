RSpec.shared_examples "a publishable model" do
  # `described_class` - это модель, в которой мы вызываем `it_behaves_like` (т.е. Article)
  let(:model_factory) { described_class.model_name.singular.to_sym }

  describe 'scopes' do
    let!(:published) { create(model_factory, published_at: 1.day.ago) }
    let!(:draft) { create(model_factory, published_at: nil) }
    let!(:scheduled) { create(model_factory, published_at: 1.day.from_now) }

    it '.published returns only published records' do
      expect(described_class.published).to contain_exactly(published)
    end

    it '.drafts returns records without a published_at or with a future published_at' do
      expect(described_class.drafts).to contain_exactly(draft, scheduled)
    end
  end

  describe 'instance methods' do
    it '#published? returns true for past published_at' do
      subject = build(model_factory, published_at: 1.day.ago)
      expect(subject.published?).to be(true)
    end

    it '#published? returns false for future published_at' do
      subject = build(model_factory, published_at: 1.day.from_now)
      expect(subject.published?).to be(false)
    end

    it '#published? returns false for nil published_at' do
      subject = build(model_factory, published_at: nil)
      expect(subject.published?).to be(false)
    end
  end
end
