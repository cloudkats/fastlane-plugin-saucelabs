# saucelabs plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-saucelabs)
[![Gem Version](https://badge.fury.io/rb/fastlane-plugin-saucelabs.svg)](https://badge.fury.io/rb/fastlane-plugin-saucelabs)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-saucelabs`, add it to your project by running:

```bash
fastlane add_plugin saucelabs
```

fastlane v2.96.0 or higher is required for all plugin-actions to function properly.

## About Sace Labs
With [Sauce Labs](https://saucelabs.com/) you can continuously test your code best. This plugin provides a set of actions to interact with Sauce Labs.

`saucelabs_upload` allows you to push build artifacts to Sauce Lab (useful for test automation) and update its description.

## Usage

To get started, first, [obtain an API token](https://appcenter.ms/settings/apitokens) in App Center. The API Token is used to authenticate with the App Center API in each call.

```ruby
saucelabs_upload(
    user_name: "sauce username",
    api_key:  "sauce api name",
    app_name: "Android.MyCustomApp.apk",
    file: 'app/build/outputs/apk/debug/app-debug.apk',
    region: 'eu'
)
```

```ruby
saucelabs_upload(
    user_name: "sauce username",
    api_key:  "sauce api name",
    app_name: "iOS.MyCustomApp.ipa",
    app_description: "my iOS build description",
    file: 'app.ipa',
    region: 'us-west-1'
)
``

### Help

Once installed, information and help for an action can be printed out with this command:

```bash
fastlane action saucelabs_upload # or any action included with this plugin
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## Resources

- [SauceLabs Status page](https://status.saucelabs.com/)
- [SauceLabs API](https://docs.saucelabs.com/dev/api/index.html)

## TODO

- [ ] Support folders
- [ ] Configure uploaded version
- [X] Support mulitple regions to upload
- [ ] Retry logic
- [ ] Timeout logic
- [X] Update description
- [ ] Test key functionality
