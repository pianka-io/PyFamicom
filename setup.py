from setuptools import setup, find_packages
from Cython.Build import cythonize
import os


def find_pyx_files(directory, exclude_dirs=None):
    if exclude_dirs is None:
        exclude_dirs = []
    pyx_files = []
    for root, _, files in os.walk(directory):
        if any(excluded in root for excluded in exclude_dirs):
            continue
        for file in files:
            if file.endswith(".pyx"):
                pyx_files.append(os.path.join(root, file))
    return pyx_files


setup(
    name="PyFamicom",
    version="0.1",
    packages=find_packages(),
    ext_modules=cythonize(
        find_pyx_files(".", exclude_dirs=[".venv"]),
        language_level=3,
        compiler_directives={
            "boundscheck": False,
            "cdivision": True,
            "cdivision_warnings": False,
            "infer_types": True,
            "initializedcheck": False,
            "nonecheck": False,
            "overflowcheck": False,
            # "profile" : True,
            # "linetrace": True,
            "wraparound": False,
            # "legacy_implicit_noexcept": True,
        }
    ),

    zip_safe=False,
)
