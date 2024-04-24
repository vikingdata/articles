--------
title: Rundeck : Install 

--------

# Rundeck: Installation

*by Mark Nielsen*  
*Copyright April 2024*

---

1. [Links](#links)
2. [APi explain](#e)
3. [Examples](#ex)
4. [Script](#s)

* * *
<a name=links></a>Links
-----

General
* [My previous article](https://github.com/vikingdata/articles/tree/main/tools/automation/rundeck)
* API
    * [Getting Started with the API](https://docs.rundeck.com/docs/api/api_basics.html#running-the-welcome-project-and-new-user-token-creation)
    * [API Reference](https://docs.rundeck.com/docs/api/)
    * [API index](https://docs.rundeck.com/docs/api/#index)

----
* * *
<a name=e></a>API explained a little 
-----
From https://stackoverflow.com/questions/47671193/running-a-rundeck-job-from-a-rest-api

To run a job....
```
curl -X POST http://rundeck_server:port/api/19/job/87bdc26ce-9893-49bd-ad7a-97f4c4a39196/run?authtoken=AVy8jZdcpTYOyPcOVbfcfOQmB6b92zRu --header "Content-Type:text/json"
```
* POST is th type of command you need for this request.
    * Refer to the [API index](https://docs.rundeck.com/docs/api/#index) if you need to use GET, POST, DELETE ot other. 
* 19 is the version. I will use 47.
* 87bdc26ce-9893-49bd-ad7a-97f4c4a39196 is job version
    * You can look this by selecting a Project, then select the job, and the uuid be be printed at the top. 
* AVy8jZdcpTYOyPcOVbfcfOQmB6b92zRu

Thus the first thing is to get a token. Do the first part of this webpage :[The Rundeck API](https://docs.rundeck.com/docs/api/api_basics.html#running-the-welcome-project-and-new-user-token-creation). Ignore Postman. Then select a Project and then a Job. Get the UUID for the job (at the top of the screen).


----
* * *
<a name=ex></a>Examples
-----

To get a list of modules

* uuid = 7cc433fb-d657-428b-b045-7455708721ba
* version = 47
* api key = qw8QovPQzh6LPBBu5aXFTVyouNGlIOyr
    * deleted after this article is done

* To get a list plugins
```
curl -X GET http://localhost:4440/api/47/plugin/list?authtoken=qw8QovPQzh6LPBBu5aXFTVyouNGlIOyr | python3 -m json.tool

```

* Execute job : ca79bcf7-c5e3-4ea0-b4f6-6ddc7555c709
```
curl -X POST http://localhost:4440/api/47/job/ca79bcf7-c5e3-4ea0-b4f6-6ddc7555c709/run?authtoken=qw8QovPQzh6LPBBu5aXFTVyouNGlIOyr | python3 -m json.tool

```

* Output

```
{
    "id": 72,
    "href": "http://localhost:4440/api/47/execution/72",
    "permalink": "http://localhost:4440/project/scripts4/execution/show/72",
    "status": "running",
    "project": "scripts4",
    "executionType": "user",
    "user": "admin",
    "date-started": {
        "unixtime": 1713927256204,
        "date": "2024-04-24T02:54:16Z"
    },
    "job": {
        "id": "ca79bcf7-c5e3-4ea0-b4f6-6ddc7555c709",
        "averageDuration": 2613,
        "name": "chain",
        "group": "",
        "project": "scripts4",
        "description": "",
        "href": "http://localhost:4440/api/47/job/ca79bcf7-c5e3-4ea0-b4f6-6ddc7555c709",
        "permalink": "http://localhost:4440/project/scripts4/job/show/ca79bcf7-c5e3-4ea0-b4f6-6ddc7555c709"
    },
    "description": "Plugin[exec-command, nodeStep: true] [... 2 steps]",
    "argstring": null,
    "serverUUID": "c13b2855-5b12-4fd2-be62-a12e1efb8e0a"
}
```

* Get status : GET /api/47/execution/72
    * ``` curl -X GET http://localhost:4440/api/47/execution/72?authtoken=qw8QovPQzh6LPBBu5aXFTVyouNGlIOyr| python3 -m json.tool```
* Output

```
{
    "id": 72,
    "href": "http://localhost:4440/api/47/execution/72",
    "permalink": "http://localhost:4440/project/scripts4/execution/show/72",
    "status": "succeeded",
    "project": "scripts4",
    "executionType": "user",
    "user": "admin",
    "date-started": {
        "unixtime": 1713927256204,
        "date": "2024-04-24T02:54:16Z"
    },
    "date-ended": {
        "unixtime": 1713927257427,
        "date": "2024-04-24T02:54:17Z"
    },
    "job": {
        "id": "ca79bcf7-c5e3-4ea0-b4f6-6ddc7555c709",
        "averageDuration": 2335,
        "name": "chain",
        "group": "",
        "project": "scripts4",
        "description": "",
        "href": "http://localhost:4440/api/47/job/ca79bcf7-c5e3-4ea0-b4f6-6ddc7555c709",
        "permalink": "http://localhost:4440/project/scripts4/job/show/ca79bcf7-c5e3-4ea0-b4f6-6ddc7555c709"
    },
    "description": "Plugin[exec-command, nodeStep: true] [... 2 steps]",
    "argstring": null,
    "serverUUID": "c13b2855-5b12-4fd2-be62-a12e1efb8e0a",
    "successfulNodes": [
        "server4"
    ]
}

```


----
* * *
<a name=s></aRun a job script
-----

Here's  python script to run a job. You must know the job id, and authorization token and optionally the base url.

[https://raw.githubusercontent.com/vikingdata/articles/main/tools/automation/rundeck/rundeck_files/Rundeck_submit_job.py](https://raw.githubusercontent.com/vikingdata/articles/main/tools/automation/rundeck/rundeck_files/Rundeck_submit_job.py)