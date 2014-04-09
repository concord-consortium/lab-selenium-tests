lab-selenium-tests
==================

Selenium tests of Lab Framework and Lab Interactives Site

Results:
http://lab4.dev.concord.org/selenium/

Installation 
====

1. Install [imagemagick](http://www.imagemagick.org/):

    Mac with [homebrew](http://brew.sh/) available:
    ```
    brew install imagemagick
    ```
    
    Ubuntu:
    ```
    sudo apt-get install imagemagick
    ```

2. Clone the lab-selenium-tests git repository to your computer:

    ```
    git clone https://github.com/concord-consortium/lab-selenium-tests.git
    ```
3. Go to the folder where you cloned the repository and run the following command to install dependencies:

    ```
    bundle install
    ```




Usage
====

### test.rb

`test.rb` lets you start screenshot generation on desired platform.

`test.rb -h` shows description and available options:


```
Usage: test.rb [options]

Specific options:
    -b, --browser BROWSER            Browser that should be tested (Chrome, Safari, Firefox, IE9, IE10, IE11, iPad,
                                     Android), default Chrome.
    -p, --platform PLATFORM          Platform (OS) that should be tested (OSX_10_8, OSX_10_9, Win_7, Win_8, Win_8_1,
                                     Linux), by default platform is chosen automatically (each browser has related
                                     default platform).
                                     Note that enforcing platform can cause an error, as not every browser and platform
                                     combination is supported by SauceLabs and BrowserStack.
    -l, --lab LAB_ENVIRONMENT        Lab environment (production, staging or dev), default dev.
    -c, --cloud CLOUD                Cloud environment (SauceLabs or BrowserStack), default SauceLabs.
    -n, --name NAME                  Test name, by default created automatically.
    -a, --attempts MAX_ATTEMPTS      Maximum number of attempts to accomplish the test in case of errors, default 25.
    -i, --interactives i1,i2,i3      List of interactives to test, by default interactives.json is downloaded
                                     and all public, curricular interactives are tested.
```

Examples:

`./test.rb -b Chrome` starts Chrome tests on SauceLabs.

`./test.rb -b Firefox -c BrowserStack` starts Firefox tests on BrowserStack.

`./test.rb -b Safari -l production` starts Safari tests using production release of Lab.

`./test.rb -b Firefox -p OS_X_10_9` starts Firefox tests on OSX 10.9 (note that screenshots comparison results may be affected as reference screenshots are taken on default platform for given browser!).

Results are always saved to `screenshots/test_<test_name>` folder. Also `screenshots/index.html` page should present new entry.

### rm-old-tests.rb

`rm-old-tests.rb` lets you remove old tests.

`rm-old-tests.rb COUNT` removes first COUNT tests results (`screenshots/test_<test_name>`) and updates `screenshots/index.html` page.

lab4.dev
====

lab-selenium-tests is installed on *lab4.dev.concord.org* server.
You can run tests there if you can log as `deploy` user:
```
ssh deploy@lab4.dev.concord.org
cd /var/www/lab-selenium-tests
```

Test results: http://lab4.dev.concord.org/selenium/
