(defpackage #:qlot/source/ql
  (:nicknames #:qlot.source.ql)
  (:use #:cl
        #:qlot/source/base)
  (:import-from #:qlot/source/dist
                #:source-dist
                #:source-dist-project
                #:source-distribution)
  (:import-from #:qlot/errors
                #:invalid-definition)
  (:import-from #:qlot/utils/ql
                #:quicklisp-distinfo-url)
  (:export #:source-ql
           #:source-ql-all))
(in-package #:qlot/source/ql)

(defclass source-ql (source-dist-project)
  ())

(defmethod initialize-instance ((source source-ql) &rest initargs &key distribution)
  ;; Just to ignore :distribution
  (declare (ignore initargs distribution))
  (call-next-method))

(defmethod source-distribution ((source source-ql))
  (quicklisp-distinfo-url))

(defclass source-ql-all (source-dist)
  ()
  (:default-initargs
    :distribution (quicklisp-distinfo-url)))

;; For backward-compatibility
;; source-ql-dist will be replaced by source-dist
(defmethod initialize-instance :around ((source source-ql-all) &rest initargs)
  (let* ((source (apply #'call-next-method source initargs))
         (source (apply #'change-class source 'source-dist initargs)))
    (setf (slot-value source 'qlot/source/base::initargs) initargs)
    source))

(defmethod make-source ((source (eql :ql)) &rest args)
  (handler-case
      (destructuring-bind (project-name &rest initargs) args
        (check-type project-name (or string (eql :all)))
        ;; Assuming :latest if there's no arguments
        (let ((initargs (or initargs '(:latest))))
          (destructuring-bind (version &key distribution) initargs
            (check-type version (or string (eql :latest)))

            (let ((distribution (or distribution
                                    (quicklisp-distinfo-url))))
              (if (eq project-name :all)
                  (make-instance 'source-dist
                                 :project-name "quicklisp"
                                 :distribution distribution
                                 :%version version)
                  (make-instance 'source-ql
                                 :project-name project-name
                                 :%version version))))))
    (error ()
      (error 'invalid-definition
             :source :ql
             :usage "ql <project name> [<version>]"))))
