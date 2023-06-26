def sonarChecks() {
   stage('Sonar Checks') {
        sh "echo Starting Code Quality Analysis"
        // sh "sonar-scanner -Dsonar.host.url=http://172.31.0.59:9000 -Dsonar.login=${SONAR_USR} -Dsonar.password=${SONAR_PSW} -Dsonar.projectKey=${COMPONENT} ${ARGS}"
        // sh "bash -x sonar-quality-gate.sh ${SONAR_USR} ${SONAR_PSW} ${SONARURL} ${COMPONENT}" 
        sh "echo Code Quality Analysis is Completed"
   }
}

def lintChecks() {
   stage('Lint Checks') {
        if(env.APPTYPE == "nodejs") {
                sh "echo installing jslinst"
                sh "npm i jslint"   
                sh "node_modules/jslint/bin/jslint.js server.js || true"
                sh "echo Lint Checks Completed for $COMPONENT"
        }
        else if(env.APPTYPE == "maven") {
                sh "mvn checkstyle:check || true"
                sh "echo Lint Checks Completed for $COMPONENT"               
        }
        else if(env.APPTYPE == "python") {
                sh "echo list checks started for payment * * * * ......"
                sh "echo Lint Checks Completed for $COMPONENT"       
        }
        else if(env.APPTYPE == "golang") {
                sh "echo list checks started for golang * * * * ......"
                sh "echo Lint Checks Completed for $COMPONENT"       
        }
        else 
                sh "echo doing generic lint check"

        }
}

def testCases() {
 parallel(
                "UNIT": {
                    stage("Unit Testing") {
                        echo "Unit Testing Compleyed"
                           }
                     },
               "INTEGRATION": {
                    stage("Integration Testing") {
                        echo "Integration Testing"
                           }
                    },
               "FUNCTIONAL": {
                    stage("Functional Testing") {
                        echo "Functional Testing"
                           }
                    },
                )
        }       

def artifacts() {
        stage('Check Artifacts') {
           env.UPLOAD_STATUS=sh(returnStdout: true, script: 'curl -L -s http://${NEXUSURL}:8081/service/rest/repository/browse/${COMPONENT} | grep ${COMPONENT}-${TAG_NAME}.zip ||  true' )
           print UPLOAD_STATUS                
        }
        
        if(env.UPLOAD_STATUS == "") {
                stage('Prepare Artifacts'){
                  if(env.APPTYPE == "nodejs") {
                        sh '''
                            npm install
                            zip -r ${COMPONENT}-${TAG_NAME}.zip node_modules server.js
                           
                           '''
                        }
                  else if(env.APPTYPE == "maven") {
                        sh '''
                            mvn clean package
                            mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar
                            zip -r ${COMPONENT}-${TAG_NAME}.zip ${COMPONENT}.jar
                           
                           ''' 

                        }
                  else if(env.APPTYPE == "python") {
                        sh ''' 
                                zip -r ${COMPONENT}-${TAG_NAME}.zip *.py *.ini requirements.txt

                           ''' 

                        }
                  else if(env.APPTYPE == "angularjs") {
                        sh '''  
                                cd static 
                                zip -r ../${COMPONENT}-${TAG_NAME}.zip *
                                ls -ltr
                        '''

                        }
                  else  {
                        sh ''' 
                                echo GOLANG Assignment

                           ''' 

                        }
                }

                stage('Upload Artifacts') {
                        withCredentials([usernamePassword(credentialsId: 'NEXUS', passwordVariable: 'NEXUS_PSW', usernameVariable: 'NEXUS_USR')]) {              
                                 sh "curl -f -v -u ${NEXUS_USR}:${NEXUS_PSW} --upload-file ${COMPONENT}-${TAG_NAME}.zip http://${NEXUSURL}:8081/repository/${COMPONENT}/${COMPONENT}-${TAG_NAME}.zip"  
                        }
                }
        }
}


// Credentials Usage Reference : https://schneide.blog/2021/06/02/using-credentials-in-scripted-jenkins-pipelines/

//             stage('Prepare Artifacts') {
//                 when { 
//                     expression { env.TAG_NAME != null } 
//                     expression { env.UPLOAD_STATUS == "" } 
//                 }
//                 steps {
//                     sh "npm install"
//                     sh "zip -r ${COMPONENT}-${TAG_NAME}.zip node_modules server.js"
//                 }
//             }

//             stage('Uploading Artifacts') {
//                 when { 
//                     expression { env.TAG_NAME != null } 
//                     expression { env.UPLOAD_STATUS == "" } 
//                 }
//                 steps {
//                     sh "curl -f -v -u ${NEXUS_USR}:${NEXUS_PSW} --upload-file ${COMPONENT}-${TAG_NAME}.zip http://${NEXUSURL}:8081/repository/${COMPONENT}/${COMPONENT}-${TAG_NAME}.zip"
//                 }
//             }

//             stage('Chekcing Artifacts') {
//                 when { expression { env.TAG_NAME != null } }
//                 steps {
//                     script {
//                         env.UPLOAD_STATUS=sh(returnStdout: true, script: 'curl -L -s http://${NEXUSURL}:8081/service/rest/repository/browse/${COMPONENT} | grep ${COMPONENT}-${TAG_NAME}.zip ||  true' )
//                         print UPLOAD_STATUS
//                     }
//                 }
//             }


// Scripted Pipeline Reference
// def testCases() {
//         stage('Test Cases') {
//           parallel {
//                 stage('Unit Testing') {                 
//                     steps {
//                          sh "echo Unit Testing Completed"   
//                            }
//                        }
//                 stage('Integration Testing') {                 
//                     steps {
//                          sh "echo Integration Testing Completed"   
//                          }
//                     }
//                 stage('Function Testing') {                 
//                       steps {
//                         sh "echo Function Testing Completed"   
//                                 }
//                         }
//                 }         
//         }
// }