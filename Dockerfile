# select  official nodejs image
FROM node:16            

# make working directory inside container
WORKDIR /app           

# copy all json files to container
COPY package*.json ./   

# install dependencies
RUN npm install        

# copy all files to container
COPY . .                

# build the react app
RUN npm run build      

# expose the app
EXPOSE 3000            

# start the react app when container starts
CMD ["npm","start"]     
