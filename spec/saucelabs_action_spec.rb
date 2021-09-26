describe Fastlane::Actions::SaucelabsAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The saucelabs plugin is working!")

      Fastlane::Actions::SaucelabsAction.run(nil)
    end
  end
end
