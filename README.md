lab-selenium-tests
==================

Selenium tests of Lab Framework and Lab Interactives Site

Usage
====
`test.rb` lets you start screenshot generation on desired platform.

`test.rb -h` shows description and available options:


```
Usage: test.rb [options]

Specific options:
    -b, --browser BROWSER            Browser that should be tested (Chrome, Safari, Firefox, IE9, IE10, iPad), default Chrome
    -l, --lab LAB_ENVIRONMENT        Lab environment (production, staging or dev), default dev
    -c, --cloud CLOUD                Cloud environment (SauceLabs or BrowserStack), default SauceLabs
    -n, --name NAME                  Test name, by default created automatically
    -a, --attempts MAX_ATTEMPTS      Maximum number of attempts to accomplish the test in case of errors, default 25
    -i, --interactives i1,i2,i3      List of interactives to test, by default interactives.json is downloaded
                                     and all public, curricular interactives are tested
```

Examples:

`./test.rb -b Chrome` starts Chrome tests on SauceLabs.

`./test.rb -b Firefox -c BrowserStack` starts Firefox tests on BrowserStack.

`./test.rb -b Safari -l production` starts Safari tests using production release of Lab.

Results are always saved to `screenshots/test_<test_name>` folder. Also `screenshots/index.html` page should present new entry.
