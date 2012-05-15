Example usage:

    rake tarsier:run tests_path=test_app/test output=tmp


Advanced usage that probably doesn't work:

    RAILS_ENV=test rake loris:run tests_path=engines/corporate_pages/test/unit/corporate_pages/ output=result.txt add_silencers="/\/rails_ext\//" --trace
