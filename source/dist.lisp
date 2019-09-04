(defpackage #:qlot.source.dist
  (:nicknames #:qlot/source/dist)
  (:use #:cl
        #:qlot/source/base)
  (:import-from #:qlot/utils/ql
                #:make-versioned-distinfo-url)
  (:export #:source-dist
           #:source-distribution
           #:source-distinfo
           #:source-distinfo-url))
(in-package #:qlot/source/dist)

(defclass source-dist-base (source)
  ((%version :initarg :%version)
   (distribution :initarg :distribution)
   (%distinfo :accessor source-distinfo)))

(defclass source-dist (source-dist-base) ())

(defmethod source-distribution ((source source-dist-base))
  (cond
    ((slot-boundp source 'qlot/source/base::version)
     (make-versioned-distinfo-url (slot-value source 'distribution)
                                  (subseq (source-version source) (length (source-version-prefix source)))))
    ((eq (slot-value source '%version) :latest)
     (slot-value source 'distribution))
    (t
     (make-versioned-distinfo-url (slot-value source 'distribution)
                                  (slot-value source '%version)))))

(defmethod source-distinfo-url ((source source-dist-base))
  (source-distribution source))

(defmethod make-source ((source (eql :dist)) &rest initargs)
  (destructuring-bind (project-name distribution &optional (version :latest)) initargs
    (make-instance 'source-dist
                   :project-name project-name
                   :distribution distribution
                   :%version version)))

(defmethod defrost-source :after ((source source-dist-base))
  (setf (slot-value source '%version)
        (subseq (source-version source)
                (length (source-version-prefix source)))))

(defmethod print-object ((source source-dist-base) stream)
  (print-unreadable-object (source stream :type t :identity t)
    (format stream "~A ~A ~A"
            (source-project-name source)
            (source-distribution source)
            (if (slot-boundp source 'qlot/source/base::version)
                (source-version source)
                (slot-value source '%version)))))

(defmethod source= ((source1 source-dist-base) (source2 source-dist-base))
  (and (string= (source-project-name source1)
                (source-project-name source2))
       (string= (slot-value source1 'distribution)
                (slot-value source2 'distribution))
       (string= (slot-value source1 '%version)
                (slot-value source2 '%version))))
