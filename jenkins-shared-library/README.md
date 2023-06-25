# jenkins-shared-library

This respository contains all the common patters of the Jenkins Pipelines declared in the form of functions in the vars/ directory.


### Jenkins Shared Library :

As Pipeline is adopted for more and more projects in an organization, common patterns are likely to emerge. 
Oftentimes it is useful to share parts of Pipelines between various projects to reduce redundancies and keep code "DRY" [1].

Pipeline has support for creating "Shared Libraries" which can be defined in external source control repositories and loaded into existing Pipelines.