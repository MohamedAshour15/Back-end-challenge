# API Chat System
It is a system that allows creating of new applications. Each application is indentified by it's unique token. A chat application can create chats, where each one have a unique number. Similarly chats can create messages, where each message has a unique number.


## Requirements
**Docker** and **Docker Compose**


## Environment
- Ruby 2.5.1
- Rails 5.2.1
- Mysql 5.6.34
- Elasticsearch 6.5.1
- Sidekiq:5.2.7
- Redis


## Setup
- Run `docker-compose up`  
- Server will be running on port `3000`
- Elasticsearch will be running on port `9200`

## Unit test
- Run `docker-compose run web bundle exec rspec`  
- Only ChatApplication controller tests are implemented.


## Api documents
-  Import the file `chat_swagger.yaml` from the repository in `https://editor.swagger.io/`



## Example

 ### Create ChatApplication
----
  Creates chat application and returns it's generated token

* **URL**

  /api/v1/chat_applications

* **Method:**

  `POST`
  
*  **URL Params**

   **Required:**
 
   `name=[string]`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ token : 'asd2goy79aksmpw }`

* **Sample Call:**

```
curl -X POST \
  http://localhost:3000/api/v1/chat_applications \
  -H 'content-type: application/json' \
  -d '{
	"name": "First chat application"
  }
```

 ### Get Messages by query
----
  Get Messages that has a body that fully or partially matches the query.

* **URL**

  /api/v1/chat_applications/:chat_application_token/chats/:chat_number/messages

* **Method:**

  `GET`
  
*  **URL Params**
 
   `query=[string]`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ messages : {body: 'Hello'} }`

* **Sample Call:**

```
curl -X POST \
  http://localhost:3000/api/v1/chat_applications/asd2goy79aksmpw/chats/1/messages?query=Hel \
  -H 'content-type: application/json' \
  -d '{
	"query": "Hel"
  }
```

## TODO
- [ ] Complete writing the unit tests
