# TensorFlow

Create mypython dirctory and mypython/model and mypython/data in vm

Upload

```
docker pull tensorflow/tensorflow
```

The -u makes prevent python from buffer stdin and stdout
```
docker run -d --name tf -v /home/rho/mypython:/tf tensorflow/tensorflow python -u /tf/batt.py \
--model_dir='/tf/model' \
--file_pathern_learn='/tf/data/move.cvs.train*' \
--file_pathern_cv='/tf/data/move.cvs.cv*' \
--no_epochs=2
```
