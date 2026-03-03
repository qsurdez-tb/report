= Roles and permissions <roles-and-permissions>

The application ICNML follows a role-based access control (RBAC) model.
Every authenticated user has one and only one role. The different roles possible
within the application are stored in the `account_type` sql table. It's reflected
on login in the Redis session object. A series of decorator are used to manage the
authorisation of each route.

The document describes each role: how they are created, what routes and database
operations are allowed, what is explicitely denied.

== Account types

There are 6 account types in the `01-account_type.sql` file.
A flag `can_singin` exists for each account type. It filters the types for which a user can request a user account
via the `GET /signin` public form.


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (center + horizon, left, center, left),
      table.header[*ID*][*Name*][*Can request account*][*Short description*],
      [1], [Administrator], [No],  [Full privileged access; manages the platform.],
      [2], [Donor],         [No],  [Subject whose biometric data is collected; created by a Submitter.],
      [3], [Submitter],     [Yes], [Registers donors.],
      [4], [Trainer],       [Yes], [Uses mark data to train fingerprint examiners.],
      [5], [AFIS],          [Yes], [Works with Automated Fingerprint Identification System targets and candidate matches.],
      [6], [Selection],     [Yes], [Selection user, not clear yet what it's useful for.],
    )
)

 