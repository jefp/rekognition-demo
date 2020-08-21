# Amazon Rekognition Workshop

## **The objective**
Create a system that takes a photo and do some basic recognition on the photo. Basically we wanted to identify the user sitting in front of the PC. The Amazon Rekognition service allows you to create one or more collections. A collection is simply as a set of facial vectors for sample photos that you tell it to save. Once you have a collection, you can then take a subject photo and have it compare the features of the subject to its reference collection, and return the closest match.

***NOTE: The service doesn’t store the actual photos, but a JSON representation of measurements obtained from a reference photo.***

#### 1.- CREATING A ROLE FOR EC2

Once you are set up on AWS, the first thing we need to do is to create an \[Amazon IAM (Identity & Access Management)\](https://aws.amazon.com/iam/) role which has the permissions to use the Rekognition service. In the Amazon console, click on ‘Services’ in the top left corner, then choose ‘IAM’ from the vast list of Amazon services. Then, on the left hand side menu, click on ‘Role’. This should show you a list of existing IAM roles that you have created on the console, if you have done so in the past. !\[\](img/s1/0.png) Click on the \*\*‘Create Role’\*\* blue button on the top of this list to add a new IAM role. !\[\](img/s1/1.png) Check \*\*EC2\*\* as service that will use the role and click \*\*Next: Permissions.\*\* !\[\](img/s1/2.png) In the policy type: type \*\*Rekognition\*\* and check the policy \*\*AmazonRekognitionFullAccess\*\* And click \*\*Next: Review\*\* !\[\](img/s1/3.png) Put as the Role Name: \*\*EC2DemoRekognitionRole\*\* and click \*\*Create role.\*\*

#### 2.- CREATING AN EC2 INSTANCE
Once you have finished the creation of the Rekognition Role, go to the \*\*EC2 service\*\*, in order to Launch a EC2 Instance. For that you can click the upper left corner option - \*\*Services\*\* and click to the \*\*EC2 Service.\*\* !\[\](img/s2/0.png) Click on \*\*Launch Instance\*\* !\[\](img/s2/1.png) Or by go into the left menu \*\*Instances\*\* and then click into \*\*Launch Instance\*\* Select AMI: Amazon Linux AMI 2017.09.1 (HVM), SSD Volume Type !\[\](img/s2/2.png) Select \*\*t2.medium\*\* as the instance type and click \*\*Next: Configure Instance Details\*\* !\[\](img/s2/3.png) Select the IAM role created before \*\*EC2DemoRekognitionRole\*\* and click \*\*Next: Add Storage\*\* !\[\](img/s2/4.png) Add Storage if you need it, and click \*\*Next: Tags instance\*\* !\[\](img/s2/5.png) Tag your instances as: Key: \*\*Name\*\*, Value \*\*RekognitionDemo\*\* Then click \*\*Next: Configure Security Groups\*\* !\[\](img/s2/6.png) Create inbound security group to allow TCP traffic to \*\*port 443 / Source choose Anywhere\*\* and click \*\*Review and Launch\*\* 11\\. Create !\[\](img/s2/7.png) \*\*Click: Review and Launch\*\* !\[\](img/s2/8.png) \*\*Create a key pair with the name demo-rekognition and make sure to save it somewhere safe. You won’t be able to replace it.\*\* !\[\](img/s2/9.png) \*\*Launch the instance. Done!\*\* Now that your instance is launched, you need to connect to it. That is why the next part of this tutorial is AWS EC2: Connect to Linux Instance using SSH / AWS EC2: Connect to Linux Instance using PuTTY Let’s connect to the EC2 and start the funny part If you are using Windows, please check this documentation: \[https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html\](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html)

#### 3.- SETUP OUR ENVIROMENT
Execute the following commands in your instance: \*\*Install git nodejs and npm:\*\* sudo yum install -y git nodejs npm --enablerepo=epel \*\*Clone the rails app with the rekognition demo:\*\*

`git clone git://github.com/jefp/rekognition-demo.git` 

\*\*Locate in the app folder:\*\* cd rekognition-demo \*\*Install RVM and Ruby: (https://rvm.io/)\*\*

```bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB`

curl -sSL https://get.rvm.io | bash -s stable

source ~/.rvm/scripts/rvm

rvm install 2.4.1  

rvm gemset create aws-demo  

rvm gemset use aws-demo  

gem install bundler  

bundle
```

**Install NGINX and create self signed SSL certificates**

```bash
sudo openssl req -subj '/CN=demo/O=Amazon Rekognition/C=CL' -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout /tmp/server.key -out /tmp/server.crt  

sudo mkdir -p /etc/nginx/ssl/certs/  

sudo mv /tmp/server.key /tmp/server.crt /etc/nginx/ssl/certs/  

sudo mv ssl.conf /etc/nginx/conf.d  

sudo service nginx restart
``` 
                

##### **Now we have everything set to test the SDK of ruby of rekognition:**



#### 4.- TESTING REKOGNITION SDK

Once you have installed the dependencies and the SDK, we are going to use rails console to execute the app. 

```bash
source ~/.rvm/scripts/rvm 
rails c
```

**Use the following code within the rails console**

```ruby
require 'open-uri' 
file = open('https://cdn.pixabay.com/photo/2016/03/23/04/01/beautiful-1274056\_960\_720.jpg').read 

client = Aws::Rekognition::Client.new() 

response = client.detect_faces({ image: { bytes: file }, 
                                 attributes: ["ALL"] }) 
                                 
puts "Number of faces detected: #{response.face_details.count}" 

response.face_details.each do |face| 
  puts "Age: #{face.age_range.low} - #{face.age_range.high}" 
  puts "Smile: #{face.smile.value} (confidence: #{face.smile.confidence})" 
  puts "Eyeglasses: #{face.eyeglasses.value} (confidence: #{face.eyeglasses.confidence})"
  puts "Sunglasses: #{face.sunglasses.value} (confidence: #{face.sunglasses.confidence})" 
  puts "Gender: #{face.gender.value} (confidence: #{face.gender.confidence})" 
  puts "Beard: #{face.beard.value} (confidence: #{face.beard.confidence})" 
  puts "Mustache: #{face.mustache.value} (confidence: #{face.mustache.confidence})" 
  puts "Eyes Open: #{face.eyes_open.value} (confidence: #{face.eyes_open.confidence})" 
  puts "Emotions: #{face.emotions[0].type} (confidence: #{face.emotions[0].confidence})" 
end 
```

***The image we are analizing is:***
```ruby
file = open('https://cdn.pixabay.com/photo/2016/03/23/04/01/beautiful-1274056_960_720.jpg').read
```

![img](https://cdn.pixabay.com/photo/2016/03/23/04/01/beautiful-1274056_960_720.jpg)


**Try with another images:**

```ruby
file = open('https://cdn.pixabay.com/photo/2018/01/24/19/49/people-3104635__480.jpg').read 
```

![img](https://cdn.pixabay.com/photo/2018/01/24/19/49/people-3104635__480.jpg)

```ruby
file = open('https://cdn.pixabay.com/photo/2017/12/29/07/27/woman-3046960_960_720.jpg').re
```

![img](https://cdn.pixabay.com/photo/2017/12/29/07/27/woman-3046960_960_720.jpg)

```ruby
file = open('https://cdn.pixabay.com/photo/2018/02/16/14/38/portrait-3157821_960_720.jpg').read
```

![img](https://cdn.pixabay.com/photo/2018/02/16/14/38/portrait-3157821_960_720.jpg)

```ruby
file = open('https://cdn.pixabay.com/photo/2017/12/31/15/56/portrait-3052641_1280.jpg').read ```

![img](https://cdn.pixabay.com/photo/2017/12/31/15/56/portrait-3052641_1280.jpg)

#### 5.- RUN THE REKOGNITION APP

Exit from rails console using: exit To start the rails application run: puma -w 4 -d -e development Now you can access the app using the Public IP of the EC2 instance and port 443 using https protocol. You can find the public IP of the EC2 instance in the EC2 service page. Go to the \*\*EC2 service\*\*, in order to Launch a EC2 Instance. For that you can click the upper left corner option - \*\*Services\*\* and click to the \*\*EC2 Service.\*\* !\[\](img/s2/0.png) Click the EC2 instance and copy the public IP \*\*Open a firefox using the public ip and port 443\\. Example: https://52.x.x.x\*\*

\## Go Deep with some additional information ###### Amazon Rekognition – Official Documentation: \[https://docs.aws.amazon.com/es\_es/rekognition/latest/dg/what-is.html\](https://docs.aws.amazon.com/es\_es/rekognition/latest/dg/what-is.html) Amazon Rekognition – API Documentation: \[https://docs.aws.amazon.com/es\_es/rekognition/latest/dg/API\_Operations.html\](https://docs.aws.amazon.com/es\_es/rekognition/latest/dg/API\_Operations.html) Amazon Rekognition – SDK: \* RUBY: \[https://docs.aws.amazon.com/sdkforruby/api/Aws/Rekognition/Client.html\](https://docs.aws.amazon.com/sdkforruby/api/Aws/Rekognition/Client.html) \* JAVA: \[https://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/index.html\](https://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/index.html) \* Python: \[https://boto3.readthedocs.io/en/latest/reference/services/rekognition.html\](https://boto3.readthedocs.io/en/latest/reference/services/rekognition.html) \* JS: \[https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Rekognition.html\](https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Rekognition.html) \* More SDKs: \[https://aws.amazon.com/tools/?nc1=h\_ls\](https://aws.amazon.com/tools/?nc1=h\_ls)

Amazon Web Services and AWS are trademarks of Amazon.com, Inc. or its affiliates in the United States and/or other countries. This is not an official AWS project.

×

Send your message in the form below and we will get back to you as early as possible.

Name: 

Email: 

Post It! →

\### Sent your message successfully!

\### Error Sorry there was an error sending your form.
