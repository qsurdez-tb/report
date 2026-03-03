 = Roles and permissions <roles-and-permissions>
 
 The application ICNML follows a role-based access control (RBAC) model.
 Every authenticated user has one and only one role. The different roles possible
 within the application are stored in the `account_type` sql table. It's reflected 
 on login in the Redis session object. A series of decorator are used to manage the
 authorisation of each route.
 
 The document describes each role: how they are created, what routes and database
 operations are allowed, what is explicitely denied.
 
 
 