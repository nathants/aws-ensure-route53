# aws-ensure-route53

## why

managing your dns in route53 across multiple accounts should be easy.

## what

tooling to make managing your dns in route53 across multiple accounts simple and easy using [libaws](https://github.com/nathants/libaws).

## install

```
go install github.com/nathants/libaws@latest

export PATH=$PATH:$(go env GOPATH)/bin
```

or use the [dockerfile](./Dockerfile)

## usage

### bootstrap

clone this repo, and setup a new private remote. you will version your dns data here. you probably don't want this on public github.

setup your credentials using: `libaws creds-add -h`

you can now list all your credentials with: `libaws creds-ls`

### initialize

pull all your dns records across all accounts with: `bash bin/pull.sh`

commit this initial data.

your repo now looks like:

```
>> tree
├── accounts
│   ├── work-prod
│   │   └── dns.txt
│   ├── work-staging
│   │   └── dns.txt
│   ├── work-scratch
│   │   └── dns.txt
│   ├── personal-prod
│   │   └── dns.txt
│   └── personal-scratch
│       └── dns.txt
└── bin
    ├── ensure_all.sh
    ├── ensure.sh
    ├── preview_all.sh
    ├── preview.sh
    └── pull.sh
```

the dns.txt files contain entries created by [route53-ls](https://github.com/nathants/libaws/blob/master/cmd/route53/ls.go) that look like:

```
example.com example.com       Type=A     TTL=60 Value=1.1.1.1 Value=2.2.2.2
example.com cname.example.com Type=CNAME TTL=60 Value=about.us-west-2.domain.example.com
example.com alias.example.com Type=Alias        Value=d-XXX.execute-api.us-west-2.amazonaws.com     HostedZoneId=XXX
```

### update

you can now modify or add entires to these files, and deploy them.

you could make a change like:

```
>> git diff
diff --git a/accounts/work-prod/dns.txt b/accounts/work-prod/dns.txt
index 4b959e4..67415b7 100644
--- a/accounts/work-prod/dns.txt
+++ b/accounts/work-prod/dns.txt
@@ -1,4 +1,4 @@
-example.com foo.example.com Type=CNAME TTL=300 Value=bar
+example.com foo.example.com Type=CNAME TTL=300 Value=barr
```

### preview

to preview those changes, use `bash bin/preview_all.sh` or `bash bin/preview.sh work-prod`, which looks like:

```
>> bash bin/preview_all.sh
preview dns: work-prod
lib/route53.go:258: preview: route53 update Values for foo.example.com: ["bar"] => ["barr"]
preview dns: work-staging
preview dns: work-scratch
preview dns: personal-prod
preview dns: personal-scratch
```

no output means no changes.

### deploy

to deploy those changes using [route53-ensure-record](https://github.com/nathants/libaws/blob/master/cmd/route53/ensure_record.go), use `bash bin/ensure_all.sh` or `bash bin/ensure.sh work-prod`, which looks like:

```
>> bash bin/ensure_all.sh
ensure dns: work-prod
lib/route53.go:258: route53 update Values for foo.example.com: ["bar"] => ["barr"]
lib/route53.go:284: route53 updated record: foo.example.com
ensure dns: work-staging
ensure dns: work-scratch
ensure dns: personal-prod
ensure dns: personal-scratch
```

### delete

like all the [ensure](https://github.com/nathants/libaws/search?q=ensure&type=code) functions in [libaws](https://github.com/nathants/libaws), `ensure` creates or updates infrastructure as needed, but does not remove it.

to delete a record, remove it from its `dns.txt`:

```
>> git diff
diff --git a/accounts/dns/dns.txt b/accounts/dns/dns.txt
index 4b959e4..dd68522 100644
--- a/accounts/work-prod/dns.txt
+++ b/accounts/work-prod/dns.txt
@@ -1,4 +1,3 @@
-example.com foo.example.com Type=CNAME TTL=300 Value=barr
```


then preview the delete using [route53-rm-record](https://github.com/nathants/libaws/blob/master/cmd/route53/rm_record.go):

```
>> libaws route53-rm-record --preview example.com foo.example.com Type=CNAME TTL=300 Value=barr
lib/route53.go:85: preview: route53 deleted record foo.example.com: TTL=300 Type=CNAME Value=barr
```

then perform the delete using [route53-rm-record](https://github.com/nathants/libaws/blob/master/cmd/route53/rm_record.go):

```
>> libaws route53-rm-record example.com foo.example.com Type=CNAME TTL=300 Value=barr
lib/route53.go:85: route53 deleted record foo.example.com: TTL=300 Type=CNAME Value=barr
```

### monitoring

add `pull.sh` to your crontab to keep track of changes to your dns:

```
0 15 * * * bash -c 'cd ~/repos/aws-ensure-route53 && bash bin/pull.sh'
```

when you notice uncommited changes in `git status`, you can either commit them, or investigate them. foo likely should not be barr.

