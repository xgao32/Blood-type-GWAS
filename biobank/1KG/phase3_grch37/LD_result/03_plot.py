#%%
# poetry shell fewer packages than actual python on HPC /app1/ebapps/arches/flat/software/Python/3.10.8-GCCcore-12.2.0/bin/python
import pkg_resources
installed_packages = pkg_resources.working_set
installed_packages_list = sorted(["%s==%s" % (i.key, i.version) for i in installed_packages])
for package in installed_packages_list:
    print(package)


#%%
print("test")

