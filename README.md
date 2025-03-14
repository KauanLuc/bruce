# Bruce

![image](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![GitHub repo size](https://img.shields.io/github/repo-size/KauanLuc/bruce?style=for-the-badge)

Bruce is a simple command-line password manager and generator.
--
This project is extremely inspired by [pass](https://www.passwordstore.org/).

The Bruce saves your folders and credentials (or whatever you want) in a local directory called **Vault**. The default path to this directory is: `~/.bruce-vault`.
Don't worry, although the path of your passwords is known, the credentials are encrypted under a GPG public key that only your GPG private key can decrypt.

> **Note:** To run Bruce commands, you must have a pre-existing GPG key pair. Additionally, the `tree` command is required.  

If you don’t have a GPG key pair, check out [Generating a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key) for guidance.  

### **Planned Features**  

The project is still under development. Upcoming updates will include:  

- [ ] Commands to add, show, update, remove, and find credentials and folders  
- [ ] A strong password generator for credentials  
