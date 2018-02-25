cd ~/go/src/github.com/rezder/go-battleline/v2/cmd/battclients
go install
battclients -dbfile=clients.db Bot1 rebot1Er
battclients -dbfile=clients.db Bot2 rebot2Er
tar -cf defaultclientsup.tar clients.db
rm client.db
gzip defaultclientsup.tar
scp  defaultclientsup.tar.gz rho@rezder.com:/home/rho/upload/battleline/battserver/
rm defaultclientsup.tar.gz
