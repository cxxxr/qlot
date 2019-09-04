(defpackage #:qlot.source.git
  (:nicknames #:qlot/source/git)
  (:use #:cl
        #:qlot/source/base)
  (:export #:source-git
           #:source-git-remote-url
           #:source-git-ref
           #:source-git-branch
           #:source-git-tag))
(in-package #:qlot/source/git)

(defclass source-git (source)
  ((remote-url :initarg :remote-url
               :accessor source-git-remote-url)
   (ref :initarg :ref
        :initform nil
        :accessor source-git-ref)
   (branch :initarg :branch
           :initform nil
           :accessor source-git-branch)
   (tag :initarg :tag
        :initform nil
        :accessor source-git-tag)))

(defmethod make-source ((source (eql :git)) &rest initargs)
  (destructuring-bind (project-name remote-url &rest args) initargs
    (check-type project-name string)
    (check-type remote-url string)
    (apply #'make-instance 'source-git
           :project-name project-name
           :remote-url remote-url
           args)))

(defmethod defrost-source :after ((source source-git))
  (setf (source-git-ref source)
        (subseq (source-version source)
                (length (source-version-prefix source)))))

(defmethod source= ((source1 source-git) (source2 source-git))
  (and (string= (source-project-name source1)
                (source-project-name source2))
       (string= (source-git-remote-url source1)
                (source-git-remote-url source2))
       (equal (source-git-ref source1)
              (source-git-ref source2))
       (equal (source-git-branch source1)
              (source-git-branch source2))
       (equal (source-git-tag source1)
              (source-git-tag source1))))

(defmethod print-object ((source source-git) stream)
  (print-unreadable-object (source stream :type t :identity t)
    (format stream "~A ~A~:[~;~:* ~A~]"
            (source-project-name source)
            (source-git-remote-url source)
            (source-git-identifier source))))

(defun source-git-identifier (source)
  (cond
    ((source-git-ref source)
     (concatenate 'string "ref-" (source-git-ref source)))
    ((source-git-branch source)
     (concatenate 'string "branch-" (source-git-branch source)))
    ((source-git-tag source)
     (concatenate 'string "tag-" (source-git-tag source)))))
