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

== `signin_requests` table

This table stores the request for new user accounts for the types with `can_singin` true. See @roles-and-permissions.


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `signin_requests_id_seq`.],
      [`first_name`], [`varchar`],            [No],  [User's firstname from the request form],
      [`last_name`], [`varchar`],            [No], [User's lastname from the request form],
      [`email`],    [`varchar`],            [No], [User's email from the request form],
      [`account_type`], [`integer`],            [No], [Id of the account type chosen by user in request form],
      [`request_time`], [`timestamp`],            [No], [Time at which the request was sent],
      [`uuid`], [`uuid`],            [No], [Uuid of the request],
      [`validation_time`], [`timestamp`],            [Yes], [The time at which the request was validated],
      [`assertion_response`],    [`varchar`],            [Yes], [Seems linked to WebAuthn workflow],
      [`status`],    [`varchar`],            [No], [Status of the request, default to pending],
      [`username_id`],    [`integer`],            [No], [Id from the sequence of the specific role chosen (e.g. Submitter -> `username_submitter_id` sequence)],
    ),
    caption: [`signin_requests` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried

Indexes:
- No index on `id` column.

== `submissions` table


This table holds the data for creating a new donor. See @dek-donor-generation.


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `submissions_id_seqo`.],
      [`email_aes`], [`varchar`],            [No],  [Donor's email encrypted using aes],
      [`email_hash`], [`varchar`],            [No], [Donor's email hash using pbkdf2],
      [`nickname`],    [`varchar`],            [Yes], [Donor's nickname from the creation form],
      [`donor_id`], [`integer`],            [Yes], [Id of the donor from the sequence `username_donor_seq`],
      [`status`], [`varchar`],            [No], [Status of the submission, default in code to pending],
      [`created_time`], [`timestamp`],            [No], [Time at which the submission is created],
      [`update_time`], [`timestamp`],            [No], [Time at which the submission was last updated],
      [`submitter_id`],    [`integer`],            [No], [Id of the submitter],
      [`uuid`],    [`uuid`],            [No], [Uuid of the donor according to the code],
      [`consent_form`],    [`boolean`],            [No], [Whether the consent form has been uploaded or not. Default to false],
    ),
    caption: [`submissions` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit foreign key constraint on `submitter_id`. This makes the schema less readable.

Indexes:
- No index on `id` column.

== `files_type` table

Stores the different files type available in the application.


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `files_type_id_seq`.],
      [`name`], [`varchar`],            [No],  [Name of the type],
      [`desc`], [`varchar`],            [Yes], [The string to represent the type],
    ),
    caption: [`files_type` columns]
)


Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried

Indexes:
- No index on `id` column.


The default inserts are the following:
- Consent form
- Tenprint card front
- Tenprint card back
- Mark target
- Mark incidental
- TP NIST file

// TODO ask Christophe what these files are

== `files` table

This table stores the files data and its metadata like height, resolution, format, etc...

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `files_id_seq`.],
      [`creator`], [`integer`],            [Yes],  [Linked to the user creating the file, no foreign key],
      [`creation_time`], [`timestamp`],            [No], [Time at which the file is created],
      [`folder`],       [`integer`],            [Yes],  [Organisation column, there's a `exercises_folder` table, maybe should be a foreign key],
      [`filename`],       [`varchar`],            [No],  [Name of the file],
      [`type`],       [`integer`],            [Yes],  [Type of file, no foreign key],
      [`size`],       [`bigint`],            [Yes],  [Size of the file],
      [`uuid`],       [`uuid`],            [Yes],  [Uuid of the file],
      [`data`],       [`varchar`],            [Yes],  [Data of the file in UTF8],
      [`width`],       [`integer`],            [Yes],  [Width of the file],
      [`height`],       [`integer`],            [Yes],  [Height of the file],
      [`format`],       [`varchar`],            [Yes],  [Format of the file],
      [`resolution`],       [`integer`],            [Yes],  [Resolution of the file],
      [`note`],       [`varchar`],            [Yes],  [Note about the file],
      [`quality`],       [`integer`],            [Yes],  [Quality of the file, no foreign key],
    ),
    caption: [`files` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit foreign key constraint on `creator` to `users.id`.
- No explicit foreign key constraint on `folder` to, I suspect, `exercises_folder.id`
- No explicit foreign key constraint on `quality` to, I suspect, `quality_type.id`

Indexes:
- No index on `id` column.

This looks like a very broad table encompassing images and pdf alike.

== `files_v` view

This view queries all the columns from the `files` table without the data column. 

== `segments_locations` table

Stores the location and orientation of individual finger segments from a tenprint card image. // TODO check with Christophe if true


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `segments_locations_id_seq`.],
      [`tenprint_id`], [`uuid`],            [No],  [Uuid of the tenprint card, no foreign key],
      [`fpc`], [`integer`],            [No], [Finger position code (e.q. right thumb = 1), no foreign key],
      [`x`],       [`numeric`],            [No],  [x coordinate of the bounding box],
      [`y`],       [`numeric`],            [No],  [y coordinate of the bounding box],
      [`width`],       [`numeric`],            [No],  [Width of the bounding box],
      [`height`],       [`numeric`],            [No],  [Height of the bounding box],
      [`orientation`],       [`integer`],            [No],  [Orientation of the bounding box],
    ),
    caption: [`segments_locations` columns]
)


Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit foreign key constraint on `tenprint_id` to another table ? 
- No explicit foreign key constraint on `fpc` to `pc.id`

Indexes:
- No index on `id` column.

== `files_segments` table

This seems to store the actual extracted finger image data. It is used to serve the image.


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `files_segment_id_seq`.],
      [`tenprint`], [`uuid`],            [No],  [Uuid of the tenprint card, no foreign key],
      [`pc`], [`integer`],            [No], [Position code (e.q. right thumb = 1), no foreign key],
      [`data`], [`varchar`],            [No], [Data encoded UTF8],
      [`uuid`],       [`uuid`],            [No],  [Uuid of the row],
    ),
    caption: [`files_segments` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit foreign key constraint on `tenprint` to another table ? 
- No explicit foreign key constraint on `pc` to `pc.id`

Indexes:
- No index on `id` column.

== `files_segements_v` view

This view queries all the columns of the `files_segments` table expect the data column.

== `thumbnails` table

This table is used to store thumbnails of the different images. Are the thumbnails also encrypted ?


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `thumbnails_id_seq`.],
      [`uuid`], [`uuid`],            [No],  [Uuid of the row],
      [`width`],       [`integer`],            [No],  [Width of the thumbnail],
      [`height`],       [`integer`],            [No],  [Height of the thumbnail],
      [`size`],       [`integer`],            [No],  [Size of the thumbnail],
      [`data`],       [`varchar`],            [No],  [Data encoded UTF8],
      [`format`],       [`varchar`],            [No],  [Format of the thumbnail],
    ),
    caption: [`thumbnails` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried

Indexes:
- No index on `id` column.

== `quality_type` table

Stores the different quality values possible in the web applciation.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented via `newtable_id_seq`.],
      [`name`], [`varchar`],            [No],  [Name of the quality type],
    ),
    caption: [`quality_type` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No unique constraint on the `name` column, which would be interesting for enforcing business logic

Indexes:
- No index on `id` column.

Lists of quality type values:
- Prestine (typo for Pristine)
- Good
- Bad

== `tenprint_zones_location` table

Stores the possible zone location for the tenprint ? // TODO ask Christophe about this
However, I don't see it used within the application. It's never called in a sql query.


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`pc`],       [`integer`],            [No],  [Position code that also acts as a primary key, no foreign key],
      [`side`], [`varchar`],            [No],  [The side of the zone (either front or back)],
    ),
    caption: [`tenprint_zones_location` columns]
)

Constraints:
- - No explicit foreign key constraint on `pc` to `pc.id`

Indexes:
- None

Values inserted by default:
- 1, front
- 2, front
- 3, front
- 5, front
- 6, front
- 7, front
- 8, front
- 9, front
- 10, front
- 11, front
- 12, front
- 13, front
- 14, front
- 22, back
- 24, back
- 25, back
- 27, back

== `tenprint_zones` table

This table seems to be a template that would define the expected zones on a tenprint card. However, I don't see it used within the application. It's never called in a sql query.


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented with `tenprint_templates_id_seq`],
      [`pc`],       [`integer`],            [No],  [Position code, no foreign key],
      [`angle`], [`numeric(10, 0)`],            [Yes],  [Expected rotation/orientation of the finger in that zone ?],
      [`card`],       [`integer`],            [No],  [References a card type, I don't see any table that could be it ?],
      [`tl_x`],       [`numeric`],            [Yes],  [Top left x coordinate],
      [`tl_y`],       [`numeric`],            [Yes],  [Top left y coordinate],
      [`br_x`],       [`numeric`],            [Yes],  [Bottom right x coordinate],
      [`br_y`],       [`numeric`],            [Yes],  [Bottom right y coordinate],
    ),
    caption: [`tenprint_zones` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit foreign key constraint on `pc` to `pc.id`

Indexes:
- No index on `id` column.

== `mark_info` table

This table stores the information regarding a mark. 

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented with `mark_info_id_seq`],
      [`uuid`],       [`uuid`],            [No],  [Uuid for the specific row],
      [`pfsp`], [`varchar`],            [Yes],  [Police or private forensics science providers ?],
      [`detection_technic`],       [`varchar`],            [No],  [Detection technique used to retrieve the mark (e.q. Powder dusting), no foreign key],
      [`surface`],       [`varchar`],            [Yes],  [Surface on which the mark was retrieved],
    ),
    caption: [`mark_info` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit foreign key constraint on `detection_technic` to `detection_technics.id` as it's a varchar. This seems strange to me.
- No explicit foreign key constraint on `surface` to `surfaces.id` as it's a varchar. This seems strange to me.

Indexes:
- No index on `id` column.

== `gp` table

Stores the General Pattern found in fingerprints.


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented with `gp_id_seq`],
      [`name`],       [`varchar`],            [No],  [Name of the General Pattern],
      [`div_name`], [`varchar`],            [No],  [The name of the div corresponding ?],
    ),
    caption: [`gp` columns]
)


Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried

Indexes:
- No index on `id` column.

Default inserted values:
- 1, unknown, unknown
- 2, left loop, ll
- 3, right loop, rl
- 4, whorl, whorl
- 5, arch, arch
- 6, central pocket loop, cpl
- 7, double loop, dl
- 8, missing/amputated, ma
- 9, scarred/mutilated, sm

== `donor_fingers_gp` table

Many-to-Many relationship table for General pattern, Finger Position Code and Users. 

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented with `donor_fingers_gp_id_seq`],
      [`donor_id`],       [`integer`],            [No],  [Id of the donor, no foreign key],
      [`fpc`],       [`integer`],            [No],  [Id of the finger position code, no foreign key],
      [`gp`],       [`integer`],            [No],  [Id of the general pattern, no foreign key],
    ),
    caption: [`gp` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit foreign key constraint on `donor_id` to `users.id`
- No explicit foreign key constraint on `fpc` to `pc.id`
- No explicit foreign key constraint on `gp` to `gp.id`

Indexes:
- No index on `id` column.


== `pc` table

Stores the values available for the Position Code in the application.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented with `fpc_id_seq`],
      [`name`],       [`varchar`],            [No],  [Name of the finger position code],
    ),
    caption: [`pc` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit unique constraint on `name`, would be necessary to not have two pc with the same name.

Indexes:
- No index on `id` column.

Default inserted values:

- 1, Right thumb
- 2, Right index
- 3, Right middle
- 4, Right ring
- 5, Right little
- 6, Left thumb
- 7, Left index
- 8, Left middle
- 9, Left ring
- 10, Left little
- 11, Right thumb slap
- 12, Left thumb slap
- 13, Right control slap
- 14, Left control slap
- 22, Right writer palm
- 24, Left writer palm
- 25, Right lower palm
- 27, Left lower palm
- 1000, All rolled

== `detection_technics` table

Stores the available values for the detection technique in the application.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented with `detection_technics_id_seq`],
      [`name`],       [`varchar`],            [No],  [Name of the detection technique],
    ),
    caption: [`detection_technics` columns]
)


Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit unique constraint on `name`, would be necessary to not have two detection techniques with the same name.

Indexes:
- No index on `id` column.


Default inserted values:
- There are 49 default inserted values I only put the 5 first ones
- 1, Black Powder
- 2, Ninhydrine
- 3, 1,2-Indanedione
- 4, Cyanoacrylate fuming (CA)
- 5, Black Powder Suspension (BPS)
- 6, Optical

== `surfaces` table

Stores the available values for the surfaces in the application.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],            [No],  [Auto-incremented with `surfaces_id_seq`],
      [`name`],       [`varchar`],            [No],  [Name of the surface],
    ),
    caption: [`surfaces` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried
- No explicit unique constraint on `name`, would be necessary to not have two detection techniques with the same name.

Indexes:
- No index on `id` column.

Default inserted values:
- 1, Paper
- 2, Plastic
- 3, Glass
- 4, Bag
- 5, Bottle
- 6, Sticky side
- 7, Non-adhesive side
- 8, Tape
- 9, Fabric / Cloth
- 10, Metal
- 11, Cartridge
- 12, Wood
- 13, Porcelain

== `exercises` table

Stores the exercises information.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],            [`integer`],                    [No],  [Auto-incremented via `exercises_id_seq`.],
      [`uuid`],          [`uuid`],                       [No],  [Uuid of the exercise.],
      [`trainer_id`],    [`integer`],                    [No],  [Id of the trainer who created the exercise, no foreign key.],
      [`creationtime`],  [`timestamp with time zone`],   [No],  [Time at which the exercise was created.],
      [`name`],          [`character varying`],          [No],  [Name of the exercise.],
      [`active`],        [`boolean`],                    [No],  [Whether the exercise is active. Defaults to `true`.],
    ),
    caption: [`exercises` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried.
- No explicit foreign key constraint on `trainer_id` to `users.id`.

Indexes:
- No index on `id` column.

== `exercises_folder` table

This table is a many-to-many relationship table linking marks to exercise folders.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],      [`integer`],   [No],  [Auto-incremented via `exercises_folder_id_seq`.],
      [`mark`],    [`uuid`],      [No],  [Uuid of the mark, references `mark_info.uuid`, no foreign key.],
      [`folder`],  [`uuid`],      [No],  [Uuid of the folder],
    ),
    caption: [`exercises_folder` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried.
- No explicit foreign key constraint on `mark` to `mark_info.uuid`.

Indexes:
- No index on `id` column.

== `exercises_trainee_list` table

This table is a many-to-many relationship table linking trainees to exercise folders.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],       [`integer`],   [No],  [Auto-incremented via `exercises_trainee_list_id_seq`.],
      [`user_id`],  [`integer`],   [No],  [Id of the trainee, references `users.id`, no foreign key.],
      [`folder`],   [`uuid`],      [No],  [Uuid of the folder, no foreign key],
    ),
    caption: [`exercises_trainee_list` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried.
- No explicit foreign key constraint on `user_id` to `users.id`.
- No explicit foreign key constraint on `folder` to `exercises_folder.folder`.

Indexes:
- No index on `id` column.

== `activities` table

Stores the available activity values in the application.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],    [`integer`],           [No],  [Auto-incremented via `activities_id_seq`.],
      [`name`],  [`character varying`], [No],  [Name of the activity.],
    ),
    caption: [`activities` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried.
- No explicit unique constraint on `name`, would be necessary to not have two activities with the same name.

Indexes:
- No index on `id` column.

There's no default values in this table.

== `distortion` table

Stores the available distortion values in the application.

#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Column*][*Type*][*Nullable*][*Notes*],
      [`id`],    [`integer`],           [No],  [Auto-incremented via `distortion_id_seq`.],
      [`name`],  [`character varying`], [No],  [Name of the distortion type.],
    ),
    caption: [`distortion` columns]
)

Constraints:
- No explicit primary key constraint on `id`. This can hurt performance as the id column is often queried.
- No explicit unique constraint on `name`, would be necessary to not have two distortion types with the same name.

Indexes:
- No index on `id` column.

Default inserted values:
- 1, drag
- 2, twist
- 3, unknown
- 4, none

#figure(
  image(
    "../assets/db-schema.png",
    height: 80%
  ),
  caption: [Auto-generated schema of the database tables]
)
