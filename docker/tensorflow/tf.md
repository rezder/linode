# TensorFlow

Create mypython dirctory and mypython/model and mypython/data in vm

Upload

Change script:

* remove sys.path.insert 


```
docker pull tensorflow/tensorflow
```

```
docker run -d --name tf -v /home/rho/mypython:/tf tensorflow/tensorflow python /tf/batt.py \
--model_dir='/tf/model' \
--file_pathern_learn='/tf/data/move.cvs.learn*' \
--file_pathern_cv= '/tf/data/move.cvs.cv' \
--no_epochs=2
```
