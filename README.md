# iCarsoft Pre-launch Popup

Discourse theme component displaying an accessible native `<dialog>` countdown modal and sticky announcement banner for anonymous visitors prior to a scheduled forum launch.

## Settings (`settings.yml`)

- `enable_prelaunch_popup` (`bool`, default `true`): Master toggle for the component.
- `launch_date_iso` (`string`, default `"2025-12-15T00:00:00+01:00"`): Target launch timestamp in ISO 8601 format.
- `hide_after_launch` (`bool`, default `true`): Automatically suppresses and cleans up the popup and banner once `launch_date_iso` has passed.

## Development & Linting

Requires Node.js >= 22 and `pnpm` >= 10:

```sh
pnpm install
pnpm lint
```
