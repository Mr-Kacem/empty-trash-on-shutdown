# Empty Trash on Shutdown

This project automatically empties the user's Trash directory when the system shuts down.

The project currently contains:

- `empty-trash.sh`
- `empty-trash.service`
- `install.sh`
- `README.md`

At the moment, `install.sh` has not been implemented yet.

---

## What I learned

While working on this project, I learned that the Trash directory is not a universal feature of Unix systems.

It is usually provided by the desktop environment or by specific applications. On Linux desktop systems, environments such as GNOME and KDE commonly follow the FreeDesktop.org Trash specification.

This means that the Trash directory may not always exist.

For this reason, the script checks whether the Trash directory exists before trying to remove its contents.

---

## The script

The script uses the following Trash directory:

```bash
${HOME}/.local/share/Trash
```

It checks whether the directory exists:

```bash
if [[ ! -d "$TRASH_DIR" ]]; then
    exit 0
fi
```

The `-d` test checks whether the specified path exists and is a directory.

The `!` operator negates the condition.

Therefore:

```bash
[[ ! -d "$TRASH_DIR" ]]
```

means:

> If `$TRASH_DIR` does not exist as a directory.

If the Trash directory does not exist, the script exits with:

```bash
exit 0
```

An exit status of `0` means that the script terminated successfully.

The absence of a Trash directory is not considered an error because there is simply nothing to empty.

The script then removes the trashed files and their associated metadata from:

```text
~/.local/share/Trash/files/
~/.local/share/Trash/info/
```

---

## The systemd service

The project uses a system-level `systemd` service.

The service is started when the system boots and remains logically active.

The service uses:

```ini
ExecStart=/bin/true
```

The `/bin/true` command exits immediately with a successful exit status.

The following option keeps the service in the active state after `ExecStart` has finished:

```ini
RemainAfterExit=yes
```

When the system shuts down, `systemd` stops the service.

At that moment, the following command is executed:

```ini
ExecStop=/usr/local/bin/empty-trash.sh
```

This runs the Trash cleanup script during system shutdown.

Because this is a system-level service, it is not tied to the user's graphical login session.

This means that logging out before shutting down the computer does not prevent the service from running.

---

## Current service configuration

The current version of the service contains a specific Linux username:

```ini
User=pluto
Environment=HOME=/home/pluto
```

This works on my current system, but it is not portable.

A different user would have to replace `pluto` with their own Linux username.

For example:

```ini
User=jay
Environment=HOME=/home/jay
```

A future version of the project will automate this process through `install.sh`.

---

## Manual installation

The current version can be installed manually.

Copy the script to `/usr/local/bin/`:

```bash
sudo cp empty-trash.sh /usr/local/bin/empty-trash.sh
```

Make the script executable:

```bash
sudo chmod +x /usr/local/bin/empty-trash.sh
```

Copy the systemd service to `/etc/systemd/system/`:

```bash
sudo cp empty-trash.service /etc/systemd/system/
```

Reload the systemd configuration:

```bash
sudo systemctl daemon-reload
```

Enable the service so that it starts automatically at boot:

```bash
sudo systemctl enable empty-trash.service
```

Start the service:

```bash
sudo systemctl start empty-trash.service
```

Check the service status:

```bash
systemctl status empty-trash.service
```

The expected state is:

```text
active (exited)
```

---

## Testing the service

The service can be tested without shutting down the computer.

First, place a test file in the Trash.

Then stop the service manually:

```bash
sudo systemctl stop empty-trash.service
```

Stopping the service triggers:

```ini
ExecStop=/usr/local/bin/empty-trash.sh
```

The Trash should be emptied.

After the test, start the service again:

```bash
sudo systemctl start empty-trash.service
```

The service should return to:

```text
active (exited)
```

The final test is to place another file in the Trash and perform a real system shutdown.

After turning the computer on again, the Trash should be empty.

---

## Next step

The next step is to implement `install.sh`.

The installation script should automate the manual installation process.

It should:

1. Detect the Linux user who is installing the project.
2. Detect the user's home directory.
3. Copy `empty-trash.sh` to `/usr/local/bin/`.
4. Make the script executable.
5. Generate or modify the systemd service with the correct username and home directory.
6. Copy the service to `/etc/systemd/system/`.
7. Run `systemctl daemon-reload`.
8. Enable the service.
9. Start the service.
10. Verify that the service was installed correctly.

The goal is to make the project portable, so that another user can clone the repository and install it without manually editing `empty-trash.service`.
