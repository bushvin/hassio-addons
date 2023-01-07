# Home Assistant Add-on: Restick backup

This add-on allows you to create a restic backups from your Home Assistant instance local peristent folders.

For more information about restic, please visit [restic.net]

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to Supervisor -> Add-on Store.
1. Find the "Restic Backups" add-on and click it.
1. Click on the "INSTALL" button.

## Running a backup

This add-on will run and terminate, it does not keep running in the background.


You can run a backup by using the `hassio.addon_start` service:

```yml
service: hassio.addon_start
data:
  addon: acb98cac_restic
```

To perform a daily backup, you will need to add this as an automation to your Home Assistant:

```yml
- alias: Daily Backup @02:00:00
  trigger:
  - platform: time
    at: '02:00:00'
  action:
  - service: hassio.addon_start
    data:
      addon: acb98cac_restic
```

## Configuration

Add-on Configuration. More in-depth information about the options can be found here: [restic.net]

This image provides the necessary binaries for restic backups and both mysql and postgresql clients are available to export possible Home Assistant dBs prior to backups.

### Restic Repository

The place where your backups will be saved is called a “repository”. This is simply a directory containing a set of subdirectories and files created by restic to store your backups, some corresponding metadata and encryption keys.

Typically you want to do this off-system, but if you must, you can create a repository somewhere in `/share`, which is mounted as read/write.

### Restic Repository Password

The password (or key) to accompany this repository.

### Restic Hostname

Docker container hostnames may differ over restarts, causing your snapshots to have different hostnames. This field allows you to specify a fixed hostname

### Root Certificate path

When connecting to online restic repositories (like using the rest-server) you need the use of certificates. When not using publicly signed certificates (like through Let's Encrypt), you can use this field to point to a certificate to load when performing a backup.

### Pre backup commands

Commands to execute before running the backup. Execution will only fail when the last command fails.

*Create scripts on your Home Assistant instance and test it thoroughly. this typically works better than listing individual commands.*

### Post backup commands

Commands to execute after running the backup. Execution will only fail when the last command fails.

*Create scripts on your Home Assistant instance and test it thoroughly. this typically works better than listing individual commands.*

### Restic Environment variables

limited to: `AWS_ACCESS_KEY_ID`, `AWS_DEFAULT_REGION`, `AWS_PROFILE`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_SHARED_CREDENTIALS_FILE`, `AZURE_ACCOUNT_KEY`, `AZURE_ACCOUNT_NAME`, `AZURE_ACCOUNT_SAS`, `B2_ACCOUNT_ID`, `B2_ACCOUNT_KEY`, `GOOGLE_APPLICATION_CREDENTIALS`, `GOOGLE_PROJECT_ID`, `OS_APPLICATION_CREDENTIAL_ID`, `OS_APPLICATION_CREDENTIAL_NAME`, `OS_APPLICATION_CREDENTIAL_SECRET`, `OS_AUTH_TOKEN`, `OS_AUTH_URL`, `OS_PASSWORD`, `OS_PROJECT_DOMAIN_ID`, `OS_PROJECT_DOMAIN_NAME`, `OS_PROJECT_NAME`, `OS_REGION_NAME`, `OS_STORAGE_URL`, `OS_TENANT_ID`, `OS_TENANT_NAME`, `OS_TRUST_ID`, `OS_USER_DOMAIN_ID`, `OS_USER_DOMAIN_NAME`, `OS_USER_ID`, `OS_USERNAME:`, `RCLONE_BWLIMIT`, `RESTIC_COMPRESSION`, `RESTIC_KEY_HINT`, `RESTIC_PACK_SIZE`, `RESTIC_PASSWORD_COMMAND`, `RESTIC_PROGRESS_FPS`, `ST_AUTH`, `ST_KEY`, `ST_USER`

You'll need these to specify credentials to access your (private) cloud storage solutions.

### Folders

The following folders can be backed up with restic as their data is persistent across restart/reboots: `/addons`, `/backup`, `/config`, `/media`, `/share`, `/ssl`.

All these folders are mounted read-only, except for `/share` which is mounted read-write. This way you can save output from the *Pre-* and *Post Backup Commands* to `/share`

#### tags

Restic uses tags to identify snapshots. Modify the tags section to add/remove tags.

#### exclude

Provide a list of files or folders to be excluded from backup.

#### forget restic snapshots

by enabling `enable_forget`, you will automatically purge your snapshots based on the configuration specified through `keep_daily`, `keep_weekly`, `keep_monthly`, `keep_yearly` after taking a backup.

[restic.net]: https://restic.net/
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
