#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

= Example Chapter <chapter-example>
#lorem(100)

== Writing Mathematical Expressions
Here is inline math: $3^2/4^3$

or on its own line: $ (3x_a)/(y_b^2+4) $

== Inserting Images
Here is how to insert an image.

#figure(
  image("../images/PGP_101.png", width: 60%),
  caption: [
    PGP Diagram
  ]
) <pgp>

== Creating and Citing a Bibliographic Reference

This is an example of a citation from a book by Pasini @ajop15\
\
But also the Black Alps 2019 website @pas19

== Creating a Reference to Another Part of the Document

You can also add a reference to the section @inclure-du-code[]\
\
You can also add a reference to the introduction, @introduction.\
\
As shown in @pgp, you can reference a figure.

== Displaying a Simple Command or Bash

Example: Testing a bash shell command `ls`:\
\
```sh
$> ls -al test_underscore $$* "coucou"
```

== Including Code <inclure-du-code>
```C
#include <stdio.h>
int main(int argc, char* argv[])
{
   printf("Hello World!\n");
   return 0;
}
```