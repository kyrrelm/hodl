## Deploy

### Frontend

I Commands.elm endre url til riktig miljø.

``cd ./hodl-frontend``

``yarn build``

``firebase deploy``

### Backend

``git subtree push --prefix hodl-backend heroku master``