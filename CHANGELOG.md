# Change Log

## 0.1.0

Initial release. Features include:

- Add `Adhoc Jobs` tab to Sidekiq Web UI
- Read worker files defined in the configuration and display a list of workers and their respective required and optional arguments
- Allow triggering a job with arguments from the Web UI, it will always be run asynchronously
- Basic argument parsing:
  - integer string to integer
  - float string to float
  - true/false string to boolean
  - string as-is
- Test cases for:
  - Configuration and initialization
  - UI view presenter
  - Adhoc job scheduling service
  - Adhoc Jobs Web UI actions
    - List jobs
    - List Job
    - Trigger Job
