`cd dkd-parent & mvn clean package -DskipTests` for compilation
`/opt/homebrew/opt/openjdk@17/bin/java -jar dkd-admin/target/dkd-admin.jar` for running
`mysql -u root -p'' dkd < initialize_mock_data.sql` for initialize mock data
vue uni-app dev mode using hbuilderx
we are looking at vue-uni-app for the ui and we have java springboot + mysql + redis + mybatis backend and want to continue implementing on both to get full vending machine app

following @instructions.md  and we want to first formalize and standardize our design language so that we have consistency. currently the design is all over the place. some using rounded rectangles and some using circles and pills. some have solid icon over translucent rounded rectanlge, some don't. formalize a modern design language in vue uni-app, by looking at current  state of things and extracting from it the best most modern way of doing things. keep in mind things like color and more