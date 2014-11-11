# Create nginx config

1. `cp assets/bash_ncreate_config ~/.bash_ncreate_config`
2. Add `source ~/.bash_ncreate_config` to `~/.bash_profile`
3. Edit `vim ~/.bash_ncreate_config`


# Usage

## ncreate
ncreate appends *.dev* to the domainname.
Also adds it into /etc/hosts/

### New website
create fresh *mywebsite.dev* with database
```shell
ncreate mywebsite
```

### New Wordpress website
create fresh wordpress site *mywebsite.dev* with database
```shell
ncreate mywebsite wp
```

### New Laravel website
create fresh laravel site *mywebsite.dev* with database
```shell
ncreate mywebsite laravel
```

### Clone website from git repo
Clone gitrepo into *mywebsite.dev* with database
```shell
ncreate mywebsite https://github.com/user/mywebsite.git
```

### Clone Wordpress website from git repo
Clone gitrepo into wordpress site *mywebsite.dev* with database
```shell
ncreate mywebsite wp https://github.com/user/mywebsite.git
```

### Clone Laravel website from git repo
Clone gitrepo into laravel site *mywebsite.dev* with database
```shell
ncreate mywebsite laravel https://github.com/user/mywebsite.git
```


## ndeploy

### Deploy mywebsite.com to user domain directory (ex. `/home/username/domains/mywebsite.com/public_html/`)
```shell
ndeploy username mywebsite.com
```

### Deploy mywebsite.com to user domain directory (ex. `/home/username/domains/mywebsite.com/public_html/`) with git
```shell
ndeploy username mywebsite.com https://github.com/user/mywebsite.git
```

### Deploy mywebsite.com to global directory (ex. `/var/www/mywebsite.com/public_html/`)
```shell
ndeploy global mywebsite.com
```

### Deploy mywebsite.com to global directory (ex. `/var/www/mywebsite.com/public_html/`) with git
```shell
ndeploy global mywebsite.com https://github.com/user/mywebsite.git
```


## ndelete
Per now only works in global directory

### Delete site
```shell
ndelete mywebsite.com
```
