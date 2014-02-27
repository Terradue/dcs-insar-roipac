Running ROI_PAC on a Sandbox
=

### Pre-requisites


1 Start a CentOS6.5 sandbox


2 Install FFTW 

```
sudo yum install 
```

3 Install ROI_PAC 

ROI_PAC is installed using yum. It is a package available on the sandbox software repository.

Comply with the ROI\_PAC license by registering and getting your own copy of ROI_PAC

```
sudo yum install roi_pac
```

### Application deployment

Use `ciop-github` to clone the repository in the `application` volume:

```
ciop-github clone -g 
```

### Understanding the processing steps

#### Processing step `dem`
