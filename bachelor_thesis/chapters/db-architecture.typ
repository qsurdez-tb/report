= Database Architecture <db-arch>

The _ICNML_ application uses a PostgreSQL database named `icnml` owned by the `icnml` role.

All the tables, sequences and views live in the public schema. This chapter documents each object in the databse with details.

== `account_type` table

Stores the different type of account in the web application.

#figure(
   table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Primary key, auto-incremented via `accounts_types_id_seq`, indexed by `account_type_id_idx`],
      [`name`], [`character varying`],            [No],  [No unique on name],
      [`can_singin`], [`boolean`],            [No], [Default to false, flag used to mark which role can request an account via the login form],
    ),
    caption: [`account_type` columns]
)

// TODO ask if we prefer prose over bulletpoints ? 

The index on the primary key duplicates the index, this creates noise and has no real impact but it's worth noting. The `name` column has no constraint and thus a new account type named Administrator could be added. As the RBAC logic depends on the name, it would be worth adding, see @roles-and-permissions.

The column `can_singin` has a typo.


== `users` table

Stores the users account. The `type` column is a foreign key referencing the `account_type.id`. This determines the role of the user and its capabilities within the application, see @roles-and-permissions.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Primary key, auto-incremented via `users_id_seq`.],
      [`username`], [`varchar`],            [No],  [Must be unique (`users_un`). Indexed by `users_username_idx`.],
      [`password`], [`varchar`],            [Yes], [Hashed credential. Nullable to support accounts without passwork (passkey I presume).],
      [`email`],    [`varchar`],            [Yes], [Contact address, also used by the DEK derivation workflpw.],
      [`totp`],     [`varchar`],            [Yes], [TOTP secret for two-factor authentication.],
      [`active`],   [`boolean`],            [No],  [Defaults to `true`. Set to `false` to disable login without deleting the row.],
      [`type`],     [`integer`],            [No],  [FK → `account_type.id`. Determines the user's role.],
    ),
    caption: [`users` columns]
)

Constraints:
- `users_un`, unique constraint on `username`
- `users_fk`, foreign key on `type` referencing `account_type.id`

Indexes:
- `users_username_idx`, B-tree index on `username`


== `webauthn` table


This table stores WebAuthn passkey credentials registered by users. I have not yet seen how and where in the application a user can do it. // TODO check when I have an account


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `webauthn_id_seq`.],
      [`user_id`], [`integer`],            [No],  [No foreign key constraint on this column.],
      [`ukey`], [`varchar`],            [No], [Linked to WebAuthn workflow],
      [`credential_id`],    [`varchar`],            [No], [Linked to WebAuthn workflow],
      [`pub_key`],     [`varchar`],            [No], [Linked to WebAuthn workflow],
      [`sign_count`],   [`integer`],            [No],  [Linked to WebAuthn workflow],
      [`key_name`],     [`varchar`],            [Yes],  [Readable label for the key],
      [`created_on`],     [`timestamp`],            [No], [When the row was created],
      [`last_usage`],     [`timestamp`],            [Yes], [Last time the key was used],
      [`active`],     [`boolean`],            [No], [Wether the key is active or not. Default to true],
      [`usage_counter`],     [`integer`],            [No], [Linked to WebAuthn workflow],
    ),
    caption: [`webauthn` columns]
)

Constraints:
- No explicit foreign key constraint defined for `user_id` referencing `users.id`. 
- No explicit primary key constraint defined for `id`. This can hurt performance as the id column is often queried

Indexes:
- No index on `id` column.


== `cf` table

This table must store the consent forms of the donors. It's quite minimal but it stores the consent form file as `varchar` data within the database. As `varchar` expects text formatted with UTF8, an encoding might append server-side before uploading the file. A `blob` field would be better as this is made to store binary data. Or it's actually storing a file path. 


// TODO check the data what it's like in the prod db

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `cf_id_seq`.],
      [`uuid`], [`uuid`],            [No],  [Probably linked to the uuid of a submission ?],
      [`data`], [`varchar`],            [No], [Either encoded data file or a file path],
      [`email`],    [`varchar`],            [No], [Email not encrypted ?],
    ),
    caption: [`cf` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit foreign key constraint on `uuid` which is probably referencing `submission.uuid`

Indexes:
- No index on `id` column.

== `donor_dek` table

This table stores the DEK for each donor. It will store all the values necessary to generate the DEK again and check it agains the `dek_check` column.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `donor_dek_id_seq`.],
      [`donor_name`], [`varchar`],            [No],  [Probably linked to the user's username ?],
      [`salt`], [`varchar`],            [No], [Salt used in the DEK generation],
      [`iterations`],    [`integer`],            [No], [Number of iterations used in the DEK generation algorithm (limited to IntMax)],
      [`algo`], [`varchar`],            [No], [Name of the algo used in the DEK generation],
      [`hash`], [`varchar`],            [No], [Hashing algorithm used in the DEK generation],
      [`dek`], [`varchar`],            [Yes], [The actual DEK generated],
      [`dek_check`], [`varchar`],            [No], [The encrypted DEK using AES to regenerate the DEK if needed.],
    ),
    caption: [`donor_dek` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit foreign key constraint defined for `donor_name` referencing `users.username`.

Indexes:
- No index for `id` column.


