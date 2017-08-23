# Teacher App

### Getting started

- Install node. You probably should use 6.x or newer.
- Install yarn: https://yarnpkg.com/en/docs/install#mac-tab
- Follow the installation steps in the react native getting started guide:

https://facebook.github.io/react-native/docs/getting-started.html

- You may need to run the following after installing Xcode:

```
xcode-select --install
sudo xcode-select -s /Applications/Xcode.app
```

- Install node dependencies: `yarn install`
- Install carthage: `brew install carthage`
- Run a carthage checkout at the top level of the repo:
  `(cd ../.. ; carthage checkout --no-use-binaries)`
- Launch the app: `react-native run-ios`
  (note: if you already have a simulator running, kill it before running that
   command)

### BuddyBuild
In the root of the git repo is `buddybuild_postclone.sh` which will ensure that only the apps
with relevant changes will build. But because we can only cancel builds right now, the builds
in buddy build will show as failed. You should look to make sure that the Teacher App build
succeeded for all commits related to this app.

### Linting
We use the eslint config from the project http://standardjs.com/.
If needed we can customize these rules in `.eslintrc`

To lint from the command line run `yarn run lint`
You can also run `yarn run lint:fix` to tell eslint to try and fix as many errors as it knows how
To have the linter watch for changes from the command line run `yarn run lint:watch`

In VS Code you can install the extension ESLint to get linting using our .eslintrc file inside of the editor

#### Flow

Flow is installed inside of the project so if you would like to run flow you can run
`yarn run flow`. Be sure that you performed another `yarn install` to make sure you have flow installed.

If you would like to have flow working inside of VS Code install the `vscode-flow-ide` extension.
Then hit `CMD ,` and search for these two options and set them both to false:
`typescript.validate.enable`
`javascript.validate.enable`

### Testing

We use [jest](https://facebook.github.io/jest/) for testing.

To run the tests, run `yarn run test` from the command line. To have jest watch
for changes and intelligently run tests automatically run `yarn run jest -- --watch`.

To run the coverage reports use the `--coverage` flag. `yarn test -- --coverage`.

### Canvas API

#### Directory Structure

```
- src/
  - api/
    - canvas-api/
      - courses.js
      - assignments.js
```

### i18n

We use [format-message](https://github.com/format-message/format-message) to do string substitutions
for internationlization. It uses ICU message formatting for formatting strings. For an interactive demo
of how to use ICU message format see http://format-message.github.io/icu-message-format-for-translators/

When we import `format-message` we put it into a variable called `i18n` to be more clear what it is doing.
When calling `i18n` you must pass in a string literal. You can not store your string in a variable
and then pass it into `i18n`. If you do that `format-message` cannot extract that string.

To extract new strings run `yarn run extract-strings`. This will overwrite the existing `en.json` file
in `i18n/locales/`.

To add a new language just add the language strings to `<locale-code>.json` to `i18n/locales/` and then add
that new language to `i18n/locales/index.js`

### Custom default controls (i.e. Text, Button, TextInput)
Please use our [custom default controls](docs/CUSTOM_DEFAULT_CONTROLS.md) vs the default `ReactNative` controls so text and inputs use the app wide font, colors and branding where available.
