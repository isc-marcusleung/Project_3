# TrakCare Data Generator

This project is to implement a tool to help generate a large amount of realistic patient data for TrakCare System. The tool is implemented as a web application which is deployed in Iris system. In addition, the application is integrated with TrakCare System using TrakCare REST APIs.


## Scope

 1. Implement functions to generate Patient, Episode (Inpatient, Outpatient and Emergency), Order (Radiology, Consultation, Laboratory) and Observation, Radiology Results records by using TrackCare APIs 
 2. Import external data sets to create realistic clinical data
 3. Build a web page for user operation

## Environment Setup
### Develpment environment
You may use docker container to hold Iris System and TrakCare System or directly install them in your servers.

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/environment.PNG" alt="drawing" width="400"/>


### Setup
1. Create a web application for REST API which is used for Web UI integration

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/setup_web_app.png" alt="drawing" width="600"/>

2. Create a web application to hold the web page stuff

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/setup_web_app_2.png" alt="drawing" width="600"/>

3. Import the production settings. The settings include all the necessary TrakCare API calls. You need to update the TrakCare connection information in CDUI\DataGen\Production.cls before import the settings.

## High level overview of the architecture

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/architecture.png" alt="drawing" width="600"/>

## Call flow diagram

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/call_flow.png" alt="drawing" width="500"/>

## Demonstration

![alt text](https://github.com/isc-marcusleung/Project_3/blob/main/blob/demo.gif)

## Frontend Tools

Below are the tools used in the frontend development

1.  JQuery
2.  Bootstrap
3.  HTML

## Web UI 

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/ui.png" alt="drawing" width="500"/>

### Configuration Section

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/ui_configuration_section.png" alt="drawing" width="500"/>


1.  Purge Cache (^DataGen.Cache)
    1.  The cache is used to store those data used as parameter values during record creation.
    2.  You may clear the cache to free up the memory and force it to retrieve the data via TrakCare API again when you send the request next time.
2.  Purge Log
    1.  There are some logs stored in global variable "^DataGen.Log" for debugging purposes.
    2.  You may clear the log to free up the memory.
3.  Delete All API Log Files
    1.  API Log file store the information related to TrakCare API call during record creation for performance investigation purposes,
    2.  If you delete it, then the files will not be available in Job Management section.
4.  Reset All
    1.  It executes purge cache, purge log, delete all api log file, remove all job information and reset the setting.
    2.  It can also be used as a last resort if you encounter any abnormal behavior in the application.

### Job Management Section

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/ui_job_management_section.png" alt="drawing" width="500"/>

This section provides you with below functions.

1.  After you submit a job creation form, it will automatically refresh this table so you can see the job information.
2.  You can download the API log file after the job is completed.
3.  "Terminate" a job means that you can stop/kill the job when the status of the job is in "Create" or "In Progress".
4.  "Delete" a job means that it terminates the job if the status of the job is in "Create" or "In Progress" and it removes the job record from the job information list.
5.  Auto-Refresh means that if it is enabled, it will automatically retrieve the latest job information list from the backend. Currently, the interval is set to 2 seconds.
6.  "Previous" and "Next" are used to navigate the job information list. (pagination)

### Job Creation Form Section

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/ui_job_creation_form_section.png" alt="drawing" width="500"/>

This section allows you to specify the number of corresponding records to be created. If the record (B) depends on another record (A), it is enabled to input only after the number of record (A) is filled.

There are 2 modes.

1.  Specify by a number
    1.  The number of records will be created based on the number.
2.  Specify by a range
    1.  The number of records will be created within the range of the number you specify.

Reset Button

1.  Clear all the input and reset all the changes in the form.

#### Constraints Added

In the input text field, some constraints are added to guide the user to finish the form.

1.  Only number is allowed to input in the input text field.
2.  In "Specify by a number" mode, 0 is not allowed to specify the number of records.
3.  In "Specify by a range" mode, the input value in "from" must be less than or equal to the input value in "to"

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/constraint_3.png" alt="drawing" width="400"/>

4. In "Specify by a range" mode, either inputting "from" or "to" is not allowed.

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/constraint_4.png" alt="drawing" width="400"/>


### Alert Message
There are 4 types of alert message.

1. Info

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/alert_info.png" alt="drawing" width="600"/>

2. Success

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/alert_success.png" alt="drawing" width="600"/>

3. Warning

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/alert_warning.png" alt="drawing" width="600"/>

4. Error

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/alert_error.png" alt="drawing" width="600"/>



## Job Mechanism
### Six Job Statuses 
| Status      | Description |
| ----------- | ----------- |
| Create  | A job is created but a new process has not yet started to handle the request. |
| In Progress   | A new process has started to handle the request.|
| Terminated  | When the previous status is in "Create" or "In Progress" and a user manually terminates the process.|
| Completed With Error  | When the process can complete but some exceptions occur during the process.|
| Completed  | When the process can complete successfully.|
| Error   | When the process cannot be run properly.|

### Job Status Flow

<img src="https://github.com/isc-marcusleung/Project_3/blob/main/blob/job_status_flow.png" alt="drawing" width="500"/>
