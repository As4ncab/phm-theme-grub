# Project Hail Mary GRUB theme

> [!IMPORTANT]  
> I took an existing GRUB theme and only changed a few things like images and messages. Installation details and the original design can be found [here](https://github.com/shvchk/fallout-grub-theme).

Supported languages are: Chinese (simplified), Chinese (traditional), English, French, German, Hungarian, Italian, Korean, Latvian, Norwegian, Polish, Portuguese, Russian, Rusyn, Spanish, Turkish, Ukrainian

![Example of GRUB startup](mockup.png)

> [!NOTE]  
> This is just a rough example of how it would look like.

---

## Installation/Updates

> [!WARNING]  
> For this custom theme I have used the software [Grub Customizer](https://forums.linuxmint.com/viewtopic.php?t=208452) to make a custom name for each option. This software may not be available for all users.


> [!NOTE]  
> Highlights information that users should take into account, even when skimming.

> [!IMPORTANT]  
> Crucial information necessary for users to succeed.

> [!WARNING]  
> Critical content demanding immediate user attention due to potential risks.

Also available the tip and caution alerts:

> [!TIP]
> Helpful advice for doing things better or more easily.
Tip

Helpful advice for doing things better or more easily.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.


- **Secure way:**

  - Download install script:

    ```sh
    wget -P /tmp https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh
    ```

  - Review it at `/tmp/install.sh`

  - Run it:

    ```sh
    bash /tmp/install.sh
    ```

- **Easier, less secure way** — just download and run install script:

  ```sh
  wget -O - https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh | bash
  ```

<br>

You can use `--lang` option to select language and disable interactive language selection, e.g.:

```sh
bash /tmp/install.sh --lang German
```

or

```sh
wget -O- https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh | bash -s -- --lang Korean
```

Full list of languages see in `INSTALLER_LANGS` variable in [install.sh](install.sh)

---

### See also

- [Poly light GRUB theme](https://github.com/shvchk/poly-light)
- [Poly dark GRUB theme](https://github.com/shvchk/poly-dark)
