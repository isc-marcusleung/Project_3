Class Custom.CDUI.REST.spec Extends %REST.Spec [ ProcedureBlock ]
{

XData OpenAPI [ MimeType = application/json ]
{
{
      "swagger":"2.0",
      "info":{
        "title":"New Application",
        "version":"0"
      },
      "basePath":"/csp/CDUI",
      "schemes":[
        "http"
      ],

      "paths":{
        "/cdu/GetOrders":{
          "get":{
            "x-ISC_CORS":true,
            "summary":"Get orders",
            "description":"Get ...",
            "operationId":"GetOrders",
            "produces":[
              "application/json"
            ],
            "parameters":[
            {
             "name":"_count",
             "in":"query",
             "description":"Number of records",
             "required":false,
             "type":"integer"
             },
            
            {
             "name":"category",
             "in":"query",
             "description":"Order category for filter",
             "required":false,
             "type":"string"
             }],

            "responses":{
              "200":{
                "description":"OK"
              }
            }
          }
        },
        "/cdu/GetCareProviders":{
          "get":{
            "x-ISC_CORS":true,
            "summary":"Get Care Providers",
            "description":"Get ...",
            "operationId":"GetCareProviders",
            "produces":[
              "application/json"
            ],
            "responses":{
              "200":{
                "description":"OK"
              }
            }
          }
        }
      }
  }
}

}
