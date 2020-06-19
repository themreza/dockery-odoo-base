Changes
=======
2.0.0-rc1   (2020-06-18)
------------------------
- move patch machinery downstream

2.0.0-rc0   (2020-06-18)
------------------------
- use `justfile` as task runner
- remove adminpassword _file_ support
- cleanup prelude
- improve readme
- remove unused backup dir

1.0.0   (2018-12-05)
--------------------
- out-factor base images into xoelabs/dockery-odoo-base. By generating parallel
  pre-build image foundations for base and devops iamges, we shorten build time
  and provide a generic per branch environment for production and devops.

0.9.0   (2018-11-25)
--------------------
- restructurate around :devops and :base (for production) image siblings
- incorporate odoo server api extensions based on dodoo-* click based extensions
  into devops image