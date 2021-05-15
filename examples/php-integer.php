<?php

$a = 2**62;

$b = $a + ($a - 1);
$c = ($a + $a) - 1;

printf("\$b = %d\n", $b);
printf("\$c = %d\n", $c);

printf("\$b == \$c = %s\n", ($b == $c) ? "TRUE" : "FALSE");


