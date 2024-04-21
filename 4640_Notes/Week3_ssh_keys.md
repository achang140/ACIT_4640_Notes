# SSH Keys

## Description

SSH keys are cryptographic keys that are used to authenticate and encrypt data
between two machines that communicate using the SSH protocol. SSH keys are based
on public-key cryptography, which means that each key has two parts: a public
key and a private key. The public key can be shared with anyone, while the
private key must be kept secret and protected.

The public key and the private key are mathematically related, but it is
practically impossible to derive one from the other. This means that only the
owner of the private key can decrypt the data that is encrypted with the public
key, and vice versa. This also means that anyone who has the public key can
verify that the data was signed by the owner of the private key, and not
tampered with.

SSH keys are used to establish a secure connection between a client and a
server. The client is the machine that initiates the connection, and the server
is the machine that accepts the connection. To use SSH keys, the client must
generate a key pair and copy the public key to the server. The server must store
the public key in a special file called authorized_keys, which lists the public
keys that are allowed to access the server. The private key must remain on the
client machine, and can be optionally protected with a passphrase.

When the client connects to the server, the server sends a challenge to the
client, which is a random string of data. The client must sign the challenge
with its private key, and send the signature back to the server. The server then
verifies the signature with the public key, and if it matches, the server grants
access to the client. This process is called public key authentication, and it
proves that the client is in possession of the private key without revealing it
to the server.

## Key Types / Algorithms

- Digital Signature Algorithm (DSA)
- Rivest-Shamir-Adleman (RSA)
- Elliptic Curve DSA (ECDSA)
- [EdDSA and Ed25519 (Edwards-curve Digital Signature Algorithm)](https://cryptobook.nakov.com/digital-signatures/eddsa-and-ed25519)

## Key File Formats

- OpenSSH Specific Format (PPK)
- PEM (Privacy Enhanced Mail) PKCS8
- RFC4716


# Tasks

## Create SSH Key Pair Locally

1.[ssh-keygen Manual Page](https://man.openbsd.org/ssh-keygen)

1. Demo

   ```bash
   ssh-keygen -C "demo_key" \
   -f "./demo_key.pem" \
   -m PEM \
   -t ed25519 \
   -N ""
   ```

1. Explanation
   - `ssh-keygen` the command to generate, manage and convert authentication
     keys for ssh.
   - `-C "demo_key"` specifies a comment to be included in the key file.
   - `-f "./demo_key.pem"` specifies the filename of the key file.
   - `-m PEM` specifies the format of the key file.
   - `-t ed25519` specifies the type of key (algorithm) to create.
   - `-N ""` specifies the passphrase of the key file in this case empty.
   - This command creates two files in the current directory:
     - `demo_key.pem` - the private key file - note that this key is only
       readable by the user that created it.
     - `demo_key.pem.pub` - the public key file

## Upload Local SSH Key to AWS

1. [AWS EC2 User Guide for Linux Instances: Import public key to Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws)

1. [AWS CLI Command Reference: aws ec2 import-key-pair](https://docs.aws.amazon.com/cli/latest/reference/ec2/import-key-pair.html)

1. Demo

   ```bash
   aws ec2 import-key-pair \
   --key-name "demo_key" \
   --public-key-material fileb://./demo_key.pem.pub \
   --tag-specifications 'ResourceType=key-pair,Tags=[{Key=project,Value=demo}]'
   ```

1. Explanation

   - `aws ec2 import-key-pair` the AWS CLI command to import the public key of
     an existing key pair that you created with a third-party tool. A key pair
     consists of a public key that AWS stores and a private key file that you
     store. You use the key pair to securely connect to your EC2 instances1.
   - `--key-name "demo_key"` specifies the name of the public key.
   - `--public-key-material fileb://./demo_key.pem.pub` specifies the path to
     the public key file. The file must be in the OpenSSH public key or PEM
     format.
   - `--tag-specifications 'ResourceType=key-pair,Tags=[{Key=project,Value=demo}]'`
     specifies the tags to assign to the key pair. In this case, the tag has a
     key of project and a value of demo, and the resource type is key-pair.

## Create Key Pair AWS SSH Key Pair

1. [AWS EC2 User Guide for Linux Instances: Create key pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html)

1. [AWS CLI Command Reference: aws ec2 create-key-pair](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-key-pair.html)

1. Demo

   ```bash
   aws ec2 create-key-pair \
   --key-name "demo_key" \
   --key-type ed25519 \
   --key-format pem \
   --tag-specifications 'ResourceType=key-pair,Tags=[{Key=project,Value=demo}]' \
   --query "KeyMaterial" > demo_key.pem
   ```

1. Explanation

   - `aws ec2 create-key-pair` the AWS CLI command to create a key pair. A key
     pair consists of a public key that AWS stores and a private key file that
     you store. You use the key pair to securely connect to your EC2
     instances12.
   - `--key-name "demo_key"` specifies the name of the public key.
   - `--key-type ed25519` specifies the type of the key pair. Amazon EC2
     supports ED25519 and 2048-bit SSH-2 RSA keys
   - `--key-format pem` specifies the format of the key pair. Amazon EC2
     supports pem and ppk formats. PEM is the default format.
   - `--tag-specifications 'ResourceType=key-pair,Tags=[{Key=project,Value=demo}]'`
     specifies the tags to assign to the key pair. In this case, the tag has a
     key of project and a value of demo, and the resource type is key-pair.
   - `--query "KeyMaterial"` specifies the JMESPath expression to filter the
     output of the command. JMESPath is a query language for JSON data that
     allows you to select and manipulate data elements. In this case, the query
     returns only the value of the KeyMaterial property, which is the private
     key in PEM format.
   - `> demo_key.pem` redirects the output of the command to a file named
     demo_key.pem. This file contains the private key that you need to securely
     connect to your EC2 instances. You should store this file in a safe and
     secure location and it needs to be readable by your user only.

## Describe Key Pair

1. [AWS EC2 User Guide for Linux Instances: Describe public keys](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/describe-keys.html)
1. [AWS CLI Command Reference: aws ec2 describe-key-pairs](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-key-pairs.html)
1. Demo
   ```bash
   aws ec2 describe-key-pairs --key-names demo_key
   ```
1. Explanation

   - `aws ec2 describe-key-pairs` the command to describe one or more of your
     key pairs. A key pair consists of a public key that AWS stores and a
     private key file that you store. You use the key pair to securely connect
     to your EC2 instances1.
   - `--key-names demo_key` specifies the name of the key pair to describe. You
     can specify multiple key names separated by spaces, or omit this option to
     describe all of your key pairs.

   - The output of the command is a JSON object that contains the following
     properties for each key pair:
     - KeyName - The name of the key pair.
     - KeyFingerprint - The fingerprint of the public key.
     - KeyPairId - The ID of the key pair.
     - Tags - The tags assigned to the key pair.

## Tag Key Pair

1. [AWS EC2 User Guide for Linux Instances: Tag a public key](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/tag-key-pair.html)
1. [AWS CLI Command Reference: aws ec2 create-tags](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-tags.html)
1. Demo

   ```bash
   demo_key_id=$(aws ec2 describe-key-pairs \
                 --key-names demo_key \
                 --query 'KeyPairs[0].KeyPairId' \
                 --output text)

   aws ec2 create-tags \
   --resources ${demo_key_id} \
   --tags Key=kind,Value=disposable
   ```

1. Explanation

   - `aws ec2 describe-key-pairs` the command to describe one or more of your
     key pairs.
   - `--key-names demo_key` specifies the name of the key pair to describe. You
     can specify multiple key names separated by spaces, or omit this option to
     describe all of your key pairs.
   - `--query 'KeyPairs[0].KeyPairId'` specifies the JMESPath expression to
     filter the output of the command. JMESPath is a query language for JSON
     data that allows you to select and manipulate data elements. In this case,
     the query returns an array of with a single keypair and selects only the
     value of the KeyPairId property, which is the ID of the key pair.
   - `--output text` specifies the format of the output. In this case, the
     output is text, which is the ID of the key pair.
   - `demo_key_id=$(aws ec2 describe-key-pairs ...)` runs the command and stores
     the output in a variable named demo_key_id.
   - `aws ec2 create-tags` the command to create one or more tags for a
     resource. A tag consists of a key and a value, both of which you define.
     You can use tags to organize your AWS resources, and you can use them to
     control access to resources.
   - `--resources ${demo_key_id}` specifies the ID of the key pair to tag. You
     can specify multiple resource IDs separated by spaces.
   - `--tags Key=kind,Value=disposable` specifies the tags to assign to the key
     pair. In this case, the tag has a key of kind and a value of disposable.

## Delete Key Pair

1. [AWS EC2 User Guide for Linux Instances: Delete your public key on Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/delete-key-pair.html)
1. [AWS CLI Command Reference: aws ec2 delete-key-pair](https://docs.aws.amazon.com/cli/latest/reference/ec2/delete-key-pair.html)
1. Demo
   ```bash
   aws ec2 delete-key-pair \
   --key-name demo_key
   ```
1. Explanation
   - `aws ec2 delete-key-pair` the command to delete one or more of your key
     pairs. A key pair consists of a public key that AWS stores and a private
     key file that you store. You use the key pair to securely connect to your
     EC2 instances1.
   - `--key-name demo_key` specifies the name of the key pair to delete.
