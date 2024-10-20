FROM node:16            #select  official nodejs image

WORKDIR /app            #make working directory inside container

COPY package*.json ./   #copy all json files to container

RUN npm install         #install dependencies

COPY . .                #copy all files to container

RUN npm run build       #build the react app

EXPOSE 3000             #expose the app

CMD ["npm","start"]     #start the react app when container starts